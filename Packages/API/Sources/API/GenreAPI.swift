import Foundation
import Combine

public protocol GenreService {
	func genres() -> AnyPublisher<[Genre], Error>
}

public final class GenreAPI: GenreService {
	private var decoder: JSONDecoder = {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}()
	
	private let network: NetworkDataPublisher
	private let endpoints: API.Endpoints
	
	public init(network: NetworkDataPublisher = Network(), endpoints: API.Endpoints) {
		self.network = network
		self.endpoints = endpoints
	}
	
	// To-do: Add some caching expiration/invalidation logic
	public func genres() -> AnyPublisher<[Genre], Error> {
		let url = URL(string: endpoints.genres)!
		
		let all = API.Paginated(offset: 0, limit: 20)
		
		let query: API.Query = API.Query(
			fields: GenreFields.self,
			pagination: all
		)
		
		let publisher = network
			.publisher(for: url, with: query)
			.decode(type: [Genre].self, decoder: decoder)
//			.catch { _ in
//				Just(AppData.genres)
//					.setFailureType(to: Error.self)
//					.eraseToAnyPublisher()
//			}
//			.handleEvents(receiveOutput: { genres in
//				AppData.genres = genres
//			})
			.eraseToAnyPublisher()
		
		return publisher
	}
	
	private enum GenreFields: String, APIQueryField {
		case name
	}
}
