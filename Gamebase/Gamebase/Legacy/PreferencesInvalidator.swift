//
//  PreferencesInvalidator.swift
//  Gamebase
//
//  Created by Emmanuel Unuigbe on 02/08/2021.
//

import Foundation
import Combine
import UIKit

// Fix for reducing console error: "Bound preference ___key tried to update multiple times per frame"
// When binding or observing changes to geometry to our views via preferences, there are cases when the geometry
// might change quickly over a small timeframe i.e. during custom modal transitions, scrolling - events that cause the view to
// to be re-calculated many times over.
// Sometimes this observed change causes the preferences values to be written to multiple times per frame.
typealias InvalidationIdentifier = CFTimeInterval

extension Publishers {
	// Emits a new identifier every frame up to the devices maximum FPS (30fps, 60fps) and then restarts.
	// Emission of identifer is fired on the main RunLoop.
	struct PreferencesInvalidator: Publisher {
		typealias Output = InvalidationIdentifier
		typealias Failure = Never
		
		func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
			let subscription = PreferencesInvalidatorSubscription(subscriber: subscriber)
			subscriber.receive(subscription: subscription)
		}
	}
}

private class PreferencesInvalidatorSubscription<S: Subscriber>: Subscription where S.Input == InvalidationIdentifier {
	var requested: Subscribers.Demand = .none
	var subscriber: S?
	var displayLink: CADisplayLink? = nil
	
	init(subscriber: S) {
		self.subscriber = subscriber
	}
	
	func request(_ demand: Subscribers.Demand) {
		guard demand != .none else {
			self.subscriber?.receive(completion: .finished)
			return
		}
		
		requested += demand
		
		if self.displayLink == nil && demand > .none {
			configureDisplayLink()
		}
	}
	
	func cancel() {
		subscriber = nil
		displayLink?.invalidate()
		displayLink = nil
	}
	
	private func configureDisplayLink() {
		let displayLink = CADisplayLink(target: self, selector: #selector(onRefresh))
		self.displayLink = displayLink
		self.displayLink?.add(to: RunLoop.main, forMode: .default)
	}
	
	@objc private func onRefresh(displayLink: CADisplayLink) {
		guard self.requested > .none else { return }
		
		self.requested -= .max(1)
		
		_ = self.subscriber?.receive(displayLink.timestamp)
	}
}

extension Publishers {
	static func preferencesInvalidator() -> Publishers.PreferencesInvalidator {
		return Publishers.PreferencesInvalidator()
	}
}



// view model that exposes an identifer that changes every frame.
// used for invalidating/updating SwiftUI preferences once per frame by passing this identifier
// as part of the preferences value to be used for Preferences.Value equality check.

// Note: To be used sparingly or as a last resort when you can't seem to get rid of the
// "Bound preference ___key tried to update multiple times per frame" console error
// An alternative fix could be related to how you are managing/updating your view state, your view frame/layout
// or simply re-arranging your view hierarchy.
class PreferencesInvalidatorViewModel: ObservableObject {
	private var subscription: (Cancellable & Pausable)?
	
	/* 	debug: private var logger = TimeLogger(sinceOrigin: true) */
	
	@Published var invalidatingIndentifer: InvalidationIdentifier?
	@Published private var enableInvalidation: Bool = false
	
	func startInvalidating() {
		enableInvalidation = true
		guard subscription == nil else {
			if subscription?.paused == true {
				subscription?.resume()
			}

			return
		}
		
		let invalidatorPublisher = Publishers.preferencesInvalidator()
		
		subscription = invalidatorPublisher
			.combineLatest($enableInvalidation)
			.pausableSink(.unlimited) { (identifier, shouldInvalidate) -> Bool in
				if shouldInvalidate {
					/*	debug: debugPrint("start Timer emits: \(identifier)", to: &self.logger) */
					self.invalidatingIndentifer = identifier
				}
				
				return shouldInvalidate
			}
	}
	
	func stopInvalidating() {
		enableInvalidation = false
	}
	
	func cancel() {
		subscription?.cancel()
		subscription = nil
	}
}
