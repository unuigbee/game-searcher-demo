//
//  PausableSubscriber.swift
//  Gamebase
//
//  Created by Emmanuel Unuigbe on 03/08/2021.
//
import Foundation
import Combine

protocol Pausable {
	var paused: Bool { get }
	func resume()
}

final class PausableSubscriber<Input, Failure: Error>: Subscriber, Pausable, Cancellable {
	
	let combineIdentifier = CombineIdentifier()
	let receiveValue: (Input) -> Bool
	let receiveCompletion: (Subscribers.Completion<Failure>) -> Void
	let demand: Subscribers.Demand
	
	private var subscription: Subscription? = nil
	
	var paused = false
	
	init(
		receiveValue: @escaping (Input) -> Bool,
		receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void,
		demand: Subscribers.Demand
	) {
		self.receiveValue = receiveValue
		self.receiveCompletion = receiveCompletion
		self.demand = demand
	}
	
	func cancel() {
		subscription?.cancel()
		subscription = nil
	}
	
	func receive(subscription: Subscription) {
		self.subscription = subscription
		subscription.request(demand)
	}
	
	func receive(_ input: Input) -> Subscribers.Demand {
		paused = receiveValue(input) == false
		return paused ? .none : demand
	}
	
	func receive(completion: Subscribers.Completion<Failure>) {
		receiveCompletion(completion)
		subscription = nil
	}
	
	func resume() {
		guard paused else { return }
		
		paused = false
		
		subscription?.request(demand)
	}
}

extension Publisher {
	func pausableSink(
		_ demand: Subscribers.Demand = .max(1),
		receiveCompletion: @escaping ((Subscribers.Completion<Failure>) -> Void) = { _ in },
		receiveValue: @escaping ((Output) -> Bool)
	) -> Pausable & Cancellable {
		let pausable = PausableSubscriber(
			receiveValue: receiveValue,
			receiveCompletion: receiveCompletion,
			demand: demand
		)
		
		self.subscribe(pausable)
		
		return pausable
	}
}
