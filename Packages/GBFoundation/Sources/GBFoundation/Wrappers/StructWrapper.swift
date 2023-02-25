import Foundation

public class StructWrapper<V>: NSObject, NSDiscardableContent {
	public let value: V
	
	public init(_ value: V) {
		self.value = value
	}
	
	public func beginContentAccess() -> Bool {
		return true
	}
	
	public func endContentAccess() {}
	
	public func discardContentIfPossible() {}
	
	public func isContentDiscarded() -> Bool {
		return false
	}
}
