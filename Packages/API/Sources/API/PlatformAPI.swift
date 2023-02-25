import Foundation
import Combine

public typealias Logo = Platform.Logo

public protocol PlatformService {
	func platforms() -> AnyPublisher<[Platform], Error>
	func platforms(for ids: [Int]) -> AnyPublisher<[Platform], Error>
}

public final class PlatformAPI: PlatformService {
	private var decoder: JSONDecoder = {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}()
	private let network: NetworkDataPublisher
	private let endpoints: API.Endpoints
	
	public init(
		network: NetworkDataPublisher = Network(),
		endpoints: API.Endpoints
	) {
		self.network = network
		self.endpoints = endpoints
	}
	
	public func platforms() -> AnyPublisher<[Platform], Error> {
		let url = URL(string: endpoints.platform)!
		
		let all = API.Paginated(offset: 0, limit: 200)
		
		let query: API.Query = API.Query(
			fields: PlatformFields.self,
			pagination: all
		)
		
		let publisher = network
			.publisher(for: url, with: query)
			.decode(type: [Platform].self, decoder: decoder)
//			.catch { error -> AnyPublisher<[Platform], Error> in
//				return Just(self.appData.platforms)
//					.setFailureType(to: Error.self)
//					.eraseToAnyPublisher()
//			}
//			.handleEvents(receiveOutput: { platform in
//				self.appData.platforms = platform
//			})
			.eraseToAnyPublisher()
		
		return publisher
	}
	
	public func platforms(for ids: [Int]) -> AnyPublisher<[Platform], Error> {
		let condition = API.Clause.Components(
			property: "id",
			postFix: .equalTo,
			value: ids
		)
		
		let url = URL(string: endpoints.platform)!
		let filter = API.Clause.where(condition)
		
		let query = API.Query(
			fields: PlatformFields.self,
			filters: [filter]
		)
		
		let publisher = network
			.publisher(for: url, with: query)
			.decode(type: [Platform].self, decoder: decoder)
			.flatMap(mapLogos)
			.eraseToAnyPublisher()
		
		return publisher
	}
	
	private func mapLogos(from platforms: [Platform]) -> AnyPublisher<[Platform], Error> {
		let publisher = platforms.publisher
			.setFailureType(to: Error.self)
			.flatMap(maxPublishers: .max(1), mapPlatform)
			.collect()
			.eraseToAnyPublisher()
		 
		return publisher
	}
	
	private func mapPlatform(_ platform: Platform) -> AnyPublisher<Platform, Error> {
		guard let logoId = platform.logoId
		else {
			return Just(platform)
				.setFailureType(to: Error.self)
				.eraseToAnyPublisher()
		}
		
		let condition: API.Clause.Components = .init(
			property: "id",
			postFix: .equalTo,
			value: [logoId]
		)
		
		let url = URL(string: endpoints.platform)!
		let filter = API.Clause.where(condition)
		
		let query = API.Query(
			fields: PlatformLogoFields.self,
			filters: [filter]
		)
		
		let publisher = network
			.publisher(for: url, with: query)
			.decode(type: [Logo].self, decoder: decoder)
			.map { self.map(logo: $0.first, to: platform) }
			.eraseToAnyPublisher()
		
		return publisher
	}
	
	private func map(logo: Logo?, to platform: Platform) -> Platform {
		let platform = Platform(
			id: platform.id,
			name: platform.name,
			alternativeName: platform.alternativeName,
			abbreviation: platform.abbreviation,
			category: platform.category,
			generation: platform.generation,
			logoId: platform.logoId,
			logo: logo
		)
		
		return platform
	}
	
	private enum PlatformFields: String, APIQueryField {
		case name
		case alternative_name
		case abbreviation
		case category
		case platform_logo
		case generation
	}
	
	private enum PlatformLogoFields: String, APIQueryField {
		case image_id
		case url
	}
}
