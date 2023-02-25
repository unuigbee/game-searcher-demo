import Foundation

public struct APIAuthCredentials: Codable {
	public let accessToken: String
	public let expireDuration: Int
	public let tokenType: String
	
	public init(accessToken: String, expireDuration: Int, tokenType: String) {
		self.accessToken = accessToken
		self.expireDuration = expireDuration
		self.tokenType = tokenType
	}
	
	public enum CodingKeys: String, CodingKey {
		case accessToken = "access_token"
		case expireDuration = "expires_in"
		case tokenType = "token_type"
	}
}
