import Foundation
import GBFoundation
import GamebaseFacade

final class DefaultConfigService: ConfigService {
	public private(set) var appConfig: AppConfig
	
	// MARK: - Dependencies
	
	private let bundle: Bundle
	
	public init(bundle: Bundle) {
		self.bundle = bundle
		self.appConfig = Self.makeAppConfig(from: bundle)
	}
	
	private static func makeAppConfig(from bundle: Bundle) -> AppConfig {
		guard let infoDictionary = bundle.infoDictionary else {
			fatalError("Failed to retrieve config from Info.plist")
		}
		
		do {
			let decoder = DictionaryDecoder()
			let vendorsConfig = try vendorsConfig(decoder: decoder, infoDictionary: infoDictionary)
			let environmentConfig = try decoder.decode(EnvironmentConfig.self, from: infoDictionary)
			
			return AppConfig(vendors: vendorsConfig, environment: environmentConfig)
		} catch {
			fatalError("Failed to retrieve config from Info.plist with error \(error)")
		}
	}
	
	private static func vendorsConfig(
		decoder: DictionaryDecoder,
		infoDictionary: [String: Any]
	) throws -> VendorsConfig {
		let gamebaseAPIPlistConfig = try decoder.decode(GamebaseAPIVendorPlistConfig.self, from: infoDictionary)
		let vendorPlistConfig = VendorPlistConfig(gamebaseAPIConfig: gamebaseAPIPlistConfig)
		
		return VendorsConfig(plistConfig: vendorPlistConfig)
	}
}
