import Foundation
import Combine

public protocol NetworkDataPublisher {
	func publisher(for url: URL, with query: any APIQuery) -> AnyPublisher<Data, Error>
}

public protocol DataTaskProvider {
	func publisher(for urlRequest: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), Error>
}

@available(*, deprecated, message: "Use APITaskManager, this class needs to be deleted.")
public final class Network: NetworkDataPublisher {
	private let authService: APIAuthenticationService
	private let dataTaskProvider: DataTaskProvider
	
	public init(
		authService: APIAuthenticationService = AuthenticationAPI(config: .empty),
		dataTaskProvider: DataTaskProvider = URLSession.shared
	) {
		self.authService = authService
		self.dataTaskProvider = dataTaskProvider
	}
	
	// TODO: - Add delayed retry for handling server busy / rate limited server responses and other HTTPCode responses
	public func publisher(for url: URL, with query: any APIQuery) -> AnyPublisher<Data, Error> {
		let auth = authService
			.authenticationTaskPublisher()
		
		let request = auth
			.compactMap(weak: self) { this, token in
				this.urlRequest(from: url, query, token)
			}
			.flatMap(weak: self) { this, urlRequest in
				this.dataTaskProvider
					.publisher(for: urlRequest)
					.map(\.data)
			}
			.eraseToAnyPublisher()
		
		return request
	}
	
	private func urlRequest(from url: URL, _ query: any APIQuery, _ token: AccessToken) -> URLRequest {
		var urlRequest = URLRequest(
			url: url,
			httpMethod: "POST",
			httpBody: query.body()
		)
		urlRequest.client("")
		urlRequest.bearer(token)
		urlRequest.accept("application/json")
		
		return urlRequest
	}
}

extension URLSession: DataTaskProvider {
	public func publisher(for urlRequest: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
		dataTaskPublisher(for: urlRequest)
			.mapError { error in error as Error }
			.eraseToAnyPublisher()
	}
}
