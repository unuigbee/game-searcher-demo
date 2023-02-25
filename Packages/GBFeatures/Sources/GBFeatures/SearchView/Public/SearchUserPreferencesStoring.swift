import Foundation

public protocol SearchUserPreferencesStoring {
	var searchKeywords: [String] { get async }
	func setSearchKeyWords(_ value: [String]) async
}
