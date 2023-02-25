// https://github.com/ReactiveX/RxSwift/blob/5740d313d0c08c6ecaf47da34262e512a6cd3101/RxCocoa/Foundation/NSObject%2BRx.swift
import Combine
import Foundation
import GBFoundation_ObjC

// Dealloc
public extension ExtensionsProvider where Base: AnyObject {
	/**
	 Observable sequence of message arguments that completes when object is deallocated.

	 Each element is produced before message is invoked on target object. `methodInvoked`
	 exists in case observing of invoked messages is needed.

	 In case an error occurs sequence will complete.

	 In case some argument is `nil`, instance of `NSNull()` will be sent.

	 - returns: Observable sequence of arguments passed to `selector` method.
	 */
	func sentMessagePublisher(_ selector: Selector) -> AnyPublisher<[Any], Never> {
		synchronized {
			guard let proxy: MessageSentProxy = registerMessageInterceptor(selector) else {
				return Empty()
					.eraseToAnyPublisher()
			}

			return proxy.messageSent.eraseToAnyPublisher()
		}
	}

	/**
	 Observable sequence of message arguments that completes when object is deallocated.

	 Each element is produced after message is invoked on target object. `sentMessage`
	 exists in case interception of sent messages before they were invoked is needed.

	 In case an error occurs sequence will complete.

	 In case some argument is `nil`, instance of `NSNull()` will be sent.

	 - returns: Observable sequence of arguments passed to `selector` method.
	 */
	func methodInvokedPublisher(_ selector: Selector) -> AnyPublisher<[Any], Never> {
		synchronized {
			guard let proxy: MessageSentProxy = registerMessageInterceptor(selector) else {
				return Empty()
					.eraseToAnyPublisher()
			}

			return proxy.methodInvoked.eraseToAnyPublisher()
		}
	}

	private func registerMessageInterceptor<T: MessageInterceptorSubject>(_ selector: Selector) -> T? {
		let combineSelector = Combine_selector(selector)
		let selectorReference = Combine_reference_from_selector(combineSelector)

		let subject: T
		if let existingSubject = objc_getAssociatedObject(base, selectorReference) as? T {
			subject = existingSubject
		} else {
			subject = T()
			objc_setAssociatedObject(
				base,
				selectorReference,
				subject,
				.OBJC_ASSOCIATION_RETAIN_NONATOMIC
			)
		}

		if subject.isActive {
			return subject
		}

		var error: NSError?
		let targetImplementation = Combine_ensure_observing(base, selector, &error)
		if targetImplementation == nil {
			NSLog("Error registering message interceptor %@", error ?? "Unknown")
			return nil
		}

		subject.targetImplementation = targetImplementation!

		return subject
	}
}

// MARK: Message interceptors

private protocol MessageInterceptorSubject: AnyObject {
	var isActive: Bool { get }
	var targetImplementation: IMP { get set }

	init()
}

private final class MessageSentProxy: MessageInterceptorSubject, CombineMessageSentObserver {
	typealias Element = [AnyObject]

	let messageSent = PassthroughSubject<[Any], Never>()
	let methodInvoked = PassthroughSubject<[Any], Never>()

	@objc var targetImplementation: IMP = Combine_default_target_implementation()

	var isActive: Bool {
		targetImplementation != Combine_default_target_implementation()
	}

	init() {}

	@objc func messageSent(withArguments arguments: [Any]) {
		messageSent.send(arguments)
	}

	@objc func methodInvoked(withArguments arguments: [Any]) {
		methodInvoked.send(arguments)
	}

	deinit {
		messageSent.send(completion: .finished)
		methodInvoked.send(completion: .finished)
	}
}

// MARK: NSObject + Reactive

private extension ExtensionsProvider where Base: AnyObject {
	func synchronized<T>(_ action: () -> T) -> T {
		objc_sync_enter(base)
		let result = action()
		objc_sync_exit(base)
		return result
	}
}
