import Foundation

public struct AppConfig {
	public let vendors: VendorsConfig
	public let environment: EnvironmentConfig
	
	public init(
		vendors: VendorsConfig,
		environment: EnvironmentConfig
	) {
		self.vendors = vendors
		self.environment = environment
	}
}
 
