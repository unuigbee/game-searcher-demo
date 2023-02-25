import Foundation
import Combine

public protocol CoverService {
	func covers(for ids: [Int]) -> AnyPublisher<[Cover], Error>
}

public final class CoverAPI: CoverService {
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
	
	public func covers(for ids: [Int]) -> AnyPublisher<[Cover], Error> {
		guard !ids.isEmpty else {
			return Just([])
				.setFailureType(to: Error.self)
				.eraseToAnyPublisher()
		}
		
		let url = URL(string: endpoints.covers)!
		
		let condition = API.Clause.Components(property: "id",
											  postFix: .equalTo,
											  value: ids)
		let filter = API.Clause.where(condition)
		
		let query: API.Query = API.Query(
			fields: CoverFields.self,
			filters: [filter]
		)
		
		let publisher = network
			.publisher(for: url, with: query)
			.decode(type: [Cover].self, decoder: decoder)
			.eraseToAnyPublisher()
		
		return publisher
	}
	
	private enum CoverFields: String, APIQueryField {
		case url
	}
}

