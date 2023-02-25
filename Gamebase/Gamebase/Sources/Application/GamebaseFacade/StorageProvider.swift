import Foundation
import UIKit
import GBFoundation
import GamebaseFacade

final class StorageProvider: StorageProviding {
	// MARK: - Dependencies
	
	unowned let provider: Providing
	private unowned let application: UIApplication
	
	private lazy var userDefaultsStoring: any UserDefaultsStoring = makeUserDefaultsStoring()
	private lazy var protectedUserDefaultsStoring: some AsyncValueStoring = makeProtectedUserDefaultsStoring()
	lazy var userPreferences: any UserPreferencesStoring = makeUserPreferencesStoring()
	
	// MARK: - Init
	
	init(provider: Providing, application: UIApplication) {
		self.provider = provider
		self.application = application
	}
	
	// MARK: - Factory
	
	private func makeUserPreferencesStoring() -> any UserPreferencesStoring {
		DefaultUserPreferencesStorage(storage: protectedUserDefaultsStoring)
	}
	
	private func makeProtectedUserDefaultsStoring() -> some AsyncValueStoring {
		DefaultProtectedUserDefaultsStorage(
			storage: userDefaultsStoring,
			notificationCenter: .default,
			protectedDataDidBecomeAvailableNotification: UIApplication.protectedDataDidBecomeAvailableNotification,
			protectedDataWillBecomeUnavailableNotification: UIApplication.protectedDataWillBecomeUnavailableNotification,
			isProtectedDataAvailable: application.isProtectedDataAvailable
		)
	}
	
	private func makeUserDefaultsStoring() -> any UserDefaultsStoring {
		DefaultUserDefaultsStorage(storage: .standard)
	}
}
