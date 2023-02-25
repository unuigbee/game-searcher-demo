import Foundation

public struct GamebaseAPIVendorPlistConfig {
	public let clientId: String
	public let clientSecret: String
	public let grantType: String
	public let oAuthRoot: String
	public let apiRoot: String
	
	public init(
		clientId: String,
		clientSecret: String,
		grantType: String,
		oAuthRoot: String,
		apiRoot: String
	) {
		self.clientId = clientId
		self.clientSecret = clientSecret
		self.grantType = grantType
		self.oAuthRoot = oAuthRoot
		self.apiRoot = apiRoot
	}
}

extension GamebaseAPIVendorPlistConfig: Decodable {
	private enum CodingKeys: String, CodingKey {
		case clientId = "API_CLIENT_ID"
		case clientSecret = "API_CLIENT_SECRET"
		case grantType = "API_CLIENT_GRANT_TYPE"
		case oAuthRoot = "API_OAUTH_ROOT"
		case apiRoot = "API_ROOT"
	}
}

public extension GamebaseAPIVendorConfig {
	init(plistConfig: GamebaseAPIVendorPlistConfig) {
		self.init(
			clientId: plistConfig.clientId,
			clientSecret: plistConfig.clientSecret,
			grantType: plistConfig.grantType,
			oAuthRoot: plistConfig.oAuthRoot,
			apiRoot: plistConfig.apiRoot
		)
	}
}
