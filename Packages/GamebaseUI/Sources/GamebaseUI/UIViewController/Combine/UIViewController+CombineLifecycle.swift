import Combine
import GBFoundation
import UIKit

public struct UIViewControllerLifecycleAnimated<T: UIViewController> {
	public let viewController: T
	public let isAnimated: Bool
}

public extension ExtensionsProvider where Base: UIViewController {
	var viewWillAppearPublisher: AnyPublisher<UIViewControllerLifecycleAnimated<Base>, Never> {
		methodInvokedPublisher(#selector(Base.viewWillAppear(_:)))
			.compactMap { [weak base] in base?.ext.toLifecycleAnimated(args: $0) }
			.eraseToAnyPublisher()
	}

	var viewDidAppearPublisher: AnyPublisher<UIViewControllerLifecycleAnimated<Base>, Never> {
		methodInvokedPublisher(#selector(Base.viewDidAppear(_:)))
			.compactMap { [weak base] in base?.ext.toLifecycleAnimated(args: $0) }
			.eraseToAnyPublisher()
	}

	var viewDidDisappearPublisher: AnyPublisher<UIViewControllerLifecycleAnimated<Base>, Never> {
		methodInvokedPublisher(#selector(Base.viewDidDisappear(_:)))
			.compactMap { [weak base] in base?.ext.toLifecycleAnimated(args: $0) }
			.eraseToAnyPublisher()
	}

	var isBeingDismissedPublisher: AnyPublisher<Void, Never> {
		viewDidDisappearPublisher
			.filter(\.viewController.isBeingDismissed)
			.mapToVoid()
			.eraseToAnyPublisher()
	}

	var didRemoveFromNavigationControllerPublisher: AnyPublisher<Void, Never> {
		viewDidDisappearPublisher
			.filter { $0.viewController.isBeingDismissed == false }
			.filter { $0.viewController.navigationController == nil }
			.mapToVoid()
			.eraseToAnyPublisher()
	}

	private func toLifecycleAnimated(args: [Any]) -> UIViewControllerLifecycleAnimated<Base> {
		let isAnimated = args.first as? Bool ?? false
		return UIViewControllerLifecycleAnimated(
			viewController: base,
			isAnimated: isAnimated
		)
	}
}
