import Foundation

public struct AuthConfig: Codable {
	public let clientId: String
	public let clientSecret: String
	public let grantType: String
	public let oAuthRoot: String
	
	public init(
		clientId: String,
		clientSecret: String,
		grantType: String,
		oAuthRoot: String
	) {
		self.clientId = clientId
		self.clientSecret = clientSecret
		self.grantType = grantType
		self.oAuthRoot = oAuthRoot
	}
	
	public static let empty: Self = .init(
		clientId: "",
		clientSecret: "",
		grantType: "",
		oAuthRoot: ""
	)
}
