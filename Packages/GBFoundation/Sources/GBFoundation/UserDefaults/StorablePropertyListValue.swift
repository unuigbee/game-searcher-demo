import Foundation

public protocol StorablePropertyListValue {}

extension String: StorablePropertyListValue {}
extension Array: StorablePropertyListValue where Element: StorablePropertyListValue {}

// Since Value type isn't optional, but
// can still contain nil values, we'll have to introduce this
// protocol to enable us to cast any assigned value into a type
// that we can compare against nil:
internal protocol AnyOptional {
	var isNil: Bool { get }
}

extension Optional: AnyOptional {
	var isNil: Bool { self == nil }
}
