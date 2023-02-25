import Foundation
import Combine
import GBFoundation

public typealias GameFilter = GamesAPI.GameFilter

public protocol GamesService {
	func games() -> AnyPublisher<[Game], Error>
	func games(for filter: GameFilter) -> AnyPublisher<[Game], Error>
	func game(for id: Int) -> AnyPublisher<Game, Error>
	func search(query: String, fetchingMore: Bool) -> AnyPublisher<[Game], Error>
	
	func games(nextCursor: Int) async throws -> [Game]
	func game(for id: Int) async throws -> Game
	func findGames(searchTerm: String, nextCursor: Int) async throws -> [Game]
	func games(for filter: GameFilter) async throws -> [Game]
}

// TODO: - Remove combine and pagination logic

public final class GamesAPI: GamesService {
	private let network: NetworkDataPublisher = Network()
	
	private var gameCount: Int = 0
	
	private var decoder: JSONDecoder = {
		let decoder = JSONDecoder()
		return decoder
	}()
	
	private static let pageLimit = 30
	
	private let apiTaskManager: APITaskManager
	private let endpoints: API.Endpoints
	
	public init(
		apiTaskManager: APITaskManager,
		endpoints: API.Endpoints
	) {
		self.apiTaskManager = apiTaskManager
		self.endpoints = endpoints
	}
	
	// MARK: - Async/Await
	
	public func games(nextCursor: Int) async throws -> [Game] {
		let url = URL(string: endpoints.games)!
		
		let pagination = API.Paginated(
			offset: nextCursor,
			limit: Self.pageLimit
		)
		let query = API.Query(
			fields: GameFields.self,
			pagination: pagination
		)
		
		let games: [Game] = try await apiTaskManager.execute(for: url, query: query)
		
		return games
	}
	
	public func game(for id: Int) async throws -> Game {
		let url = URL(string: endpoints.games)!
		let matchingId = API.Clause.condition(matching: id)
		let filter = API.Clause.where(matchingId)
		let query = API.Query(fields: GameFields.self, filters: [filter])
		
		let game: [Game] = try await apiTaskManager.execute(for: url, query: query)
		
		return game.first!
	}
	
	public func findGames(searchTerm: String, nextCursor: Int) async throws -> [Game] {
		let url = URL(string: endpoints.games)!
		let searchQuery = API.Search(searchTerm)
		let paginatedQuery = API.Paginated(
			offset: nextCursor,
			limit: Self.pageLimit
		)
		let query = API.Query(
			fields: GameFields.self,
			search: searchQuery,
			pagination: paginatedQuery
		)
		
		let games: [Game] = try await apiTaskManager.execute(for: url, query: query)
		
		return games
	}
	
	public func games(for filter: GameFilter) async throws -> [Game] {
		let query = API.Query(
			fields: GameFields.self,
			filters: [filter.apiClause]
		)
		
		let url = URL(string: endpoints.games)!
		
		let games: [Game] = try await apiTaskManager.execute(for: url, query: query)
		
		return games
	}
	
	// MARK: - Combine
	
	public func games() -> AnyPublisher<[Game], Error> {
		let url = URL(string: endpoints.games)!
		
		let publisher = query()
			.setFailureType(to: Error.self)
			.flatMap(weak: self) { this, query in
				this.network.publisher(for: url, with: query)
			}
			.decode(type: [Game].self, decoder: decoder)
			.handleEvents(receiveOutput: incrementGameCountSideEffect)
			.eraseToAnyPublisher()
		
		return publisher
	}

	public func games(for filter: GameFilter) -> AnyPublisher<[Game], Error> {
		let query = API.Query(
			fields: GameFields.self,
			filters: [filter.apiClause]
		)
		
		let url = URL(string: endpoints.games)!
		
		return network.publisher(for: url, with: query)
			.decode(type: [Game].self, decoder: decoder)
			.eraseToAnyPublisher()
	}
	
	public func game(for id: Int) -> AnyPublisher<Game, Error> {
		let condition = API.Clause.Components(
			property: "id",
			postFix: .equalTo,
			value: [id]
		)
		let filter = API.Clause.where(condition)
		
		let query = API.Query(fields: GameFields.self, filters: [filter])
		
		let url = URL(string: endpoints.games)!
		
		let publisher = network.publisher(for: url, with: query)
			.decode(type: [Game].self, decoder: decoder)
			.compactMap { $0.first }
			.eraseToAnyPublisher()

		return publisher
	}
	
	public func search(query: String, fetchingMore: Bool) -> AnyPublisher<[Game], Error> {
		guard query.isEmpty == false else { return .empty() }
		
		self.gameCount = fetchingMore ? gameCount : 0
		
		func paginatedSearchQuery(_ search: APISearchQuery) -> AnyPublisher<API.Query, Never> {
			Just(gameCount)
				.map { gameCount -> Int in
					gameCount == Self.pageLimit ? Self.pageLimit : gameCount
				}
				.map { offset in
					let pagination = API.Paginated(
						offset: (offset == 0 ? offset : offset + 1),
						limit: Self.pageLimit
					)
					
					return API.Query(
						fields: GameFields.self,
						search: search,
						pagination: pagination
					)
				}
				.eraseToAnyPublisher()
		}
		
		let url = URL(string: endpoints.games)!
		
		let publisher = paginatedSearchQuery(API.Search(query))
			.flatMap { self.network.publisher(for: url, with: $0) }
			.decode(type: [Game].self, decoder: decoder)
			.eraseToAnyPublisher()
		
		return publisher
	}
	
	private func query() -> AnyPublisher<API.Query, Never> {
		Just(gameCount)
			.map { gameCount -> Int in
				gameCount == Self.pageLimit ? Self.pageLimit : gameCount
			}
			.map { count in
				let pagination = API.Paginated(
					offset: (count == 0 ? count : count + 1),
					limit: Self.pageLimit
				)
				
				return API.Query(
					fields: GameFields.self,
					pagination: pagination
				)
			}
			.eraseToAnyPublisher()
	}
	
	private func incrementGameCountSideEffect(_ game: [Game]) {
		gameCount += game.count
	}
	
	private enum GameFields: String, APIQueryField {
		case name
		case summary
		case category
		case involved_companies = "involved_companies.*"
		case company = "involved_companies.company.*"
		case screenshots = "screenshots.url"
		case cover = "cover.url"
		case genres = "genres.name"
		case platforms = "platforms.*"
		case total_rating
		case total_rating_count
		case aggregated_rating
		case first_release_date
	}
	
	public struct GameFilter: Hashable {
		public let id: Int
		public let filter: Filter
		
		public init(id: Int, filter: Filter) {
			self.id = id
			self.filter = filter
		}
		
		public enum Filter: String, Hashable, CaseIterable {
			case topRated = "Top Rated"
			case fighting = "Fighting"
			case shooter = "Shooter"
			case moba = "MOBA"
			case arcade = "Adventure"
			case indie = "Indie"
			case sport = "Sport"
			case platform = "Platform"
			
			public var name: String {
				return self.rawValue
			}
		}
	}
}

private extension GamesAPI.GameFilter {
	var apiClause: API.Clause {
		switch filter {
		case .topRated:
			let condition =  API.Clause.Components(
				property: "rating",
				postFix: .greaterThanOrEqualTo,
				value: 80
			)
			return API.Clause.where(condition)
		default:
			let condition = API.Clause.Components(
				property: "rating",
				postFix: .greaterThanOrEqualTo,
				value: [id]
			)
			
			return API.Clause.where(condition)
		}
	}
}

