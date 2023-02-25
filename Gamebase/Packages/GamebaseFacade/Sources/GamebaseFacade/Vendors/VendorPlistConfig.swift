
public struct VendorPlistConfig {
	// MARK: - Internal Vendors
	public let gamebaseAPIConfig: GamebaseAPIVendorPlistConfig
	
	public init(gamebaseAPIConfig: GamebaseAPIVendorPlistConfig) {
		self.gamebaseAPIConfig = gamebaseAPIConfig
	}
}
