import Combine
import Foundation

public protocol CombineCancellableHolder {
	var cancellables: [AnyCancellable] { get set }
}

private struct AssociatedKeys {
	static var Cancellables = "Cancellables"
}

public extension CombineCancellableHolder where Self: AnyObject {
	var cancellables: [AnyCancellable] {
		get {
			PropertyStoring.getAssociatedObject(
				for: self,
				key: &AssociatedKeys.Cancellables
			) ?? []
		}
		set {
			PropertyStoring.setAssociatedObject(
				for: self,
				key: &AssociatedKeys.Cancellables,
				newValue: newValue
			)
		}
	}
}

public final class PropertyStoring {
	public static func getAssociatedObject<T>(for object: AnyObject, key: UnsafeRawPointer) -> T? {
		objc_getAssociatedObject(object, key) as? T
	}

	public static func setAssociatedObject<T>(for object: AnyObject, key: UnsafeRawPointer, newValue: T?) {
		objc_setAssociatedObject(object, key, newValue, .OBJC_ASSOCIATION_RETAIN)
	}
}
