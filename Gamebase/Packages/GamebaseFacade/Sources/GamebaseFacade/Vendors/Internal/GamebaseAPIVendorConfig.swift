import Foundation

public struct GamebaseAPIVendorConfig: Codable {
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
