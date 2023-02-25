import Foundation

extension CGRect: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(NSCoder.string(for: self).hashValue)
	}
}
