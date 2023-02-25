import Foundation
import Combine
import GBFoundation

public typealias AccessToken = String

public protocol APIAuthenticationService {
	func authenticationTaskPublisher() -> AnyPublisher<AccessToken, Error>
}

@available(*, deprecated, message: "Use APIAuthenticationTask, this class needs to be deleted.")
public final class AuthenticationAPI: APIAuthenticationService {
	private let config: AuthConfig
	private let authSession: APIOAuthTokenSession
	private let dataTaskProvider: DataTaskProvider
	
	private lazy var shareReplayTokenPublisher: AnyPublisher<AccessToken, Swift.Error> = makeShareReplayTokenPublisher()

	public init(
		config: AuthConfig,
		session: APIOAuthTokenSession? = nil,
		dataTaskProvider: DataTaskProvider = URLSession.shared
	) {
		self.config = config
		self.dataTaskProvider = dataTaskProvider
		if let session = session {
			self.authSession = session
		} else {
			self.authSession = SecurePersistedAuthTokenSession(accountID: config.clientId)
		}
	}
	
	private func makeShareReplayTokenPublisher() -> AnyPublisher<AccessToken, Swift.Error> {
		guard let urlRequest = self.makeRequestURL() else {
			return Error.invalidURL.failure()
		}
		
		let fetchPublisher = dataTaskProvider
			.publisher(for: urlRequest)
			// Catch operator doesn't seem to propogate the errors downstream to the subscriber
			// when retry completes with a failure.
			//.retry(3)
			.map(\.data)
			.decode(type: APIAuthCredentials.self, decoder: JSONDecoder())
			.update(authSession)
			.map(\.accessToken)

		let publisher = sessionToken()
			.catch { _ in fetchPublisher }
//			.mapError { error -> Error in
//				switch error {
//				case is URLError:
//					return .network
//				case is DecodingError:
//					return .parsing
//				case Error.invalidToken:
//					return .invalidToken
//				default:
//					return error as? AuthenticationAPI.Error ?? .unknown
//				}
//			}
			//.logger("authentication token")
			.shareReplay(capacity: 1)
			.eraseToAnyPublisher()
		
		return publisher
	}
	
	public func authenticationTaskPublisher() -> AnyPublisher<AccessToken, Swift.Error> {
		return shareReplayTokenPublisher
	}
	
	private func sessionToken() -> AnyPublisher<AccessToken, Swift.Error> {
		guard authSession.accessTokenIsNotExpired(), let accessToken = authSession.accessToken else {
			return Error.invalidToken.failure()
		}
	
		return Just(accessToken)
			.setFailureType(to: Swift.Error.self)
			.eraseToAnyPublisher()
	}
	
	private func makeRequestURL() -> URLRequest? {
		var urlComponents = URLComponents()
		urlComponents.scheme = "https"
		urlComponents.host = "id.twitch.tv"
		urlComponents.path = "/" + "oauth2/token"

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
	
	public enum Error: Swift.Error, CustomStringConvertible {
		case invalidURL
		case invalidToken
		case network
		case parsing
		case unknown

		public var description: String {
			switch self {
			case .invalidURL:
				return "Invalid auth request URL!"
			case .invalidToken:
				return "Auth token is invalid!"
			case .network:
				return "Auth token request failed!"
			case .parsing:
				return "Failed parsing auth response from server!"
			case .unknown:
				return "Oops something went wrong!"
			}
		}
	}
}

private extension Publisher {
	func update(_ session: APIOAuthTokenSession) -> Publishers.HandleEvents<Self>
	where Output == APIAuthCredentials {
		handleEvents(
			receiveOutput: { authCrendetials in
				session.save(
					authCrendetials.accessToken,
					accessTokenExpirationTime: authCrendetials.expireDuration
				)
			},
			receiveCompletion: { completion in
				if case .failure = completion {
					session.clearTokens()
				}
			}
		)
	}
}

