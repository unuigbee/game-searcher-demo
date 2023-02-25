import Foundation

public extension Array {
	static func compareOptionalsWithLargeNil<Element: Comparable>(lhs: Element?, rhs: Element?) -> Bool {
		switch (lhs, rhs) {
		case let(l?, r?): return l < r // Both lhs and rhs are not nil
		case (nil, _): return false    // Lhs is nil
		case (_?, nil): return true    // Lhs is not nil, rhs is nil
		}
	}
	
	func mapSelf<T>(_ transform: (Self) -> T) -> T {
		return transform(self)
	}
	
	func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
		return map { $0[keyPath: keyPath] }
	}
	
	func compactMap<T>(_ keyPath: KeyPath<Element, T?>) -> [T] {
		return compactMap { $0[keyPath: keyPath] }
	}
	
	func filter<T: Comparable>(
		where keyPath: KeyPath<Element, T>,
		is predicate: (T, T) throws -> Bool,
		_ value: T
	)
	rethrows -> [Element] {
		do {
			return try filter {
				return try predicate($0[keyPath: keyPath], value)
			}
		} catch {
			throw error
		}
	}
}

public extension Array where Element: Hashable {
	func removingDuplicates() -> [Element] {
		var addedDict = [Element: Bool]()

		return filter { addedDict.updateValue(true, forKey: $0) == nil }
	}

	mutating func removeDuplicates() {
		self = removingDuplicates()
	}
}

public extension Sequence where Element: Hashable {
	func uniqued() -> [Element] {
		var set = Set<Element>()
		return filter { set.insert($0).inserted }
	}
}

public extension Collection {
	subscript (safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}
