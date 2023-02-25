import Foundation
import GBFoundation

public struct SearchKeyword: Hashable, Then {
	public internal(set) var date: Date
	public internal(set) var name: String

	public init(name: String) {
		self.name = name
		self.date = Date()
	}
}

extension SearchKeyword: Comparable {
//	static func ==(lhs: SearchKeyword, rhs: SearchKeyword) -> Bool {
//		return lhs.name == rhs.name
//	}

	public static func <(lhs: SearchKeyword, rhs: SearchKeyword) -> Bool {
		return lhs.date < rhs.date
	}
}
