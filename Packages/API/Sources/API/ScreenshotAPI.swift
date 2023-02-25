import Foundation
import Combine

public protocol ScreenshotService {
	func screenshots(for id: [Int]) -> AnyPublisher<[Screenshot], Error>
}

public final class ScreenshotAPI: ScreenshotService {
	private let network: NetworkDataPublisher
	private let endpoints: API.Endpoints
	private var decoder: JSONDecoder = {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}()
	
	public init(network: NetworkDataPublisher = Network(), endpoints: API.Endpoints) {
		self.network = network
		self.endpoints = endpoints
	}
	
	public func screenshots(for ids: [Int]) -> AnyPublisher<[Screenshot], Error> {
		guard !ids.isEmpty else {
			return Just([])
				.setFailureType(to: Error.self)
				.eraseToAnyPublisher()
		}
		
		let url = URL(string: endpoints.screenshots)!
		
		let condition = API.Clause.Components(property: "id",
											  postFix: .equalTo,
											  value: ids)
		let filter = API.Clause.where(condition)
		
		let query: API.Query = API.Query(
			fields: ScreenshotFields.self,
			filters: [filter]
		)
		
		let publisher = network
			.publisher(for: url, with: query)
			.decode(type: [Screenshot].self, decoder: decoder)
			.eraseToAnyPublisher()
		
		return publisher
	}
	
	private enum ScreenshotFields: String, APIQueryField {
		case image_id
		case url
		case game
	}
}

