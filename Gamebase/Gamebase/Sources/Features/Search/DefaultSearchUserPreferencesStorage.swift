import Foundation
import GBFeatures
import GamebaseFacade

final class DefaultSearchUserPreferencesStorage: SearchUserPreferencesStoring {
	private let userPreferencesStorage: any UserPreferencesStoring
	
	init(userPreferencesStorage: any UserPreferencesStoring) {
		self.userPreferencesStorage = userPreferencesStorage
	}
	
	var searchKeywords: [String] {
		get async { await userPreferencesStorage.searchKeywords }
	}
	
	func setSearchKeyWords(_ value: [String]) async {
		await userPreferencesStorage.setSearchKeyWords(value)
	}
}
