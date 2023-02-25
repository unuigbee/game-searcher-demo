import Foundation

public protocol OptionalType {
	associatedtype Wrapped
	
	var value: Wrapped? { get }
}

extension Optional: OptionalType {
	/// Cast `Optional<Wrapped>` to `Wrapped?`
	public var value: Wrapped? { self }
}
