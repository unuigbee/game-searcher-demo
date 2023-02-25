import Foundation
import Combine
import Reachability

extension Publishers {
	public struct NetworkReachable: Publisher {
		public typealias Output = Reachability.Connection
		public typealias Failure = ReachabilityError
		
		public let hostname: String
		
		public init(hostname: String) {
			self.hostname = hostname
		}
		
		public func receive<S: Subscriber>(subscriber: S)
		where Failure == S.Failure, Output == S.Input {
			let subscription = NetworkReachableSubscription(subscriber: subscriber, hostname: hostname)
			subscriber.receive(subscription: subscription)
		}
	}
}

fileprivate final class NetworkReachableSubscription<S: Subscriber>: Subscription
where S.Input == Reachability.Connection, S.Failure == ReachabilityError {
	private let hostname: String
	private var subscriber: S?
	private var reachability: Reachability?
	private var requested: Subscribers.Demand = .none
	
	init(subscriber: S, hostname: String) {
		self.subscriber = subscriber
		self.hostname = hostname
	}
	
	func request(_ demand: Subscribers.Demand) {
		guard demand != .none else {
			self.subscriber?.receive(completion: .finished)
			return
		}
		
		requested += demand
		
		if reachability == nil && demand > .none {
			setupReachability()
			startReachability()
		}
	}
	
	func cancel() {
		subscriber = nil
		reachability?.stopNotifier()
		reachability = nil
	}
	
	// TODO: - Doesn't seem to work/notify when connecting/disconnecting through VPN.
	// Maybe swap out Reachability with Alamorfire's Reachability :(
	private func setupReachability() {
		do {
			self.reachability = try Reachability(hostname: hostname)
			
			self.reachability?.whenReachable = { [weak self] reachability in
				guard let `self` = self, self.requested > .none else {
					return
				}
				
				self.requested -= .max(1)
				
				_ = self.subscriber?.receive(reachability.connection)
			}
			
			self.reachability?.whenUnreachable = { [weak self] reachability in
				guard let `self` = self, self.requested > .none else {
					return
				}
				
				self.requested -= .max(1)
				
				_ = self.subscriber?.receive(reachability.connection)
			}
		} catch {
			self.subscriber?.receive(completion: .failure((error as! ReachabilityError)))
		}
	}
	
	private func startReachability() {
		do {
			try self.reachability?.startNotifier()
		} catch {
			self.subscriber?.receive(completion: .failure((error as! ReachabilityError)))
		}
	}
}

public extension Publisher {
	func networkReachable(for hostname: String = "www.google.com") -> Publishers.NetworkReachable {
		Publishers.NetworkReachable(hostname: hostname)
	}
}

