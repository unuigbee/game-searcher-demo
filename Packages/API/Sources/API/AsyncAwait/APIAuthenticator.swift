import Foundation

public protocol APIAuthenticator {
	func getToken() async throws -> String
}

public final class APIAuthenticationTask: APIAuthenticator {
	private let authSession: APIOAuthTokenSession
	private let config: AuthConfig
	private let decoder: JSONDecoder = JSONDecoder()
	
	// MARK: - Public
	
	public init(authSession: APIOAuthTokenSession, config: AuthConfig) {
		self.authSession = authSession
		self.config = config
	}
	
	public func getToken() async throws -> String {
		guard let token = getPersistedToken() else {
			return try await fetchToken()
		}
		
		return token
	}
	
	// MARK: - Private
	
	private func getPersistedToken() -> String? {
		guard authSession.accessTokenIsNotExpired(), let accessToken = authSession.accessToken else {
			return nil
		}
		
		return accessToken
	}
	
	private func fetchToken() async throws -> String {
		guard let request = makeURLRequest() else {
			throw APIError.authError(underlyingError: .invalidURL)
		}
		
		do {
			let (data, _) = try await URLSession.shared.data(for: request)
			
			let decoded = try decoder.decode(APIAuthCredentials.self, from: data)
			
			authSession.save(
				decoded.accessToken,
				accessTokenExpirationTime: decoded.expireDuration
			)
			
			return decoded.accessToken
		} catch {
			authSession.clearTokens()
			throw mapError(error: error)
		}
	}
	
	private func mapError(error: Error) -> APIError {
		if error is DecodingError {
			return APIError.authError(underlyingError: .parsing)
		}
		
		return APIError.authError(underlyingError: .unknown)
	}
	
	private func makeURLRequest() -> URLRequest? {
		guard var urlComponents = URLComponents(string: config.oAuthRoot) else {
			return nil
		}
		
		urlComponents.queryItems = [
			.init(name: "client_id", value: config.clientId),
			.init(name: "client_secret", value: config.clientSecret),
			.init(name: "grant_type", value: config.grantType)
		]
		
		guard let url = urlComponents.url else {
			return nil
		}
		
		return URLRequest(url: url, httpMethod: "POST", httpBody: nil)
	}
}

