import Foundation
import GBFoundation

public struct VendorsConfig {
	public let gamebaseAPIVendorConfig: GamebaseAPIVendorConfig
	
	public init(gamebaseAPIVendorConfig: GamebaseAPIVendorConfig) {
		self.gamebaseAPIVendorConfig = gamebaseAPIVendorConfig
	}
}

public extension VendorsConfig {
	init(plistConfig: VendorPlistConfig) {
		self.init(
			gamebaseAPIVendorConfig: .init(plistConfig: plistConfig.gamebaseAPIConfig)
		)
	}
}

public extension VendorsConfig {
	/// The idea here is following. Each `Vendor` has defined its own `Config`. Like for example `GamebaseAPIVendorConfig`.
	/// So we create an entry in the dictionary for each vendor we implement. The key for that entry will be the name of the config struct.
	/// For example:
	/// [
	///     "GamebaseAPIVendorConfig":GamebaseAPIVendorConfig()
	/// ]
	/// So each `Vendor` will query the dictionary for it's own key, expecting to find it's own `Config`.
	
	func asDictionary() -> [String: Any] {
		let encoder = DictionaryEncoder()
		let encode: (Encodable) -> [String: Any] = { encodable in
			(try? encoder.encode(encodable)) ?? [:]
		}
		
		return [
			String(describing: GamebaseAPIVendorConfig.self): encode(gamebaseAPIVendorConfig)
		]
	}
}
