import Foundation

public protocol NilOrEmptyProtocol {
	var isEmpty: Bool { get }
	var nilIfEmpty: Self? { get }
}

// MARK: - Conformance
extension Array: NilOrEmptyProtocol {}
extension String: NilOrEmptyProtocol {}
extension Set: NilOrEmptyProtocol {}
extension Dictionary: NilOrEmptyProtocol {}

// MARK: - Defaults
public extension Optional where Wrapped: NilOrEmptyProtocol {
	var nilIfEmpty: Wrapped? {
		switch self {
		case let .some(value):
			return value.isEmpty ? nil : value
		case .none:
			return nil
		}
	}
}

public extension NilOrEmptyProtocol {
	var nilIfEmpty: Self? {
		isEmpty ? nil : self
	}
}
