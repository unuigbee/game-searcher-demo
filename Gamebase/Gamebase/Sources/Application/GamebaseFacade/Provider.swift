import Foundation
import GamebaseFacade
import UIKit

final class Provider: Providing {
	// MARK: - Dependencies
	
	private unowned let application: UIApplication
	private let bundle: Bundle
	let config: any ConfigService
	
	// MARK: - Providing
	
	lazy var core: any CoreProviding = makeCoreProvider()
	@MainActor lazy var features: any FeaturesProviding = makeFeaturesProvider()
	lazy var storage: any StorageProviding = makeStorageProvider()
	
	init(
		application: UIApplication,
		bundle: Bundle
	) {
		self.application = application
		self.bundle = bundle
		self.config = DefaultConfigService(bundle: bundle)
	}
	
	// MARK: - Factory
	
	private func makeCoreProvider() -> any CoreProviding {
		CoreProvider(provider: self)
	}
	
	@MainActor
	private func makeFeaturesProvider() -> any FeaturesProviding {
		FeaturesProvider(provider: self)
	}
	
	private func makeStorageProvider() -> any StorageProviding {
		StorageProvider(provider: self, application: application)
	}
}
