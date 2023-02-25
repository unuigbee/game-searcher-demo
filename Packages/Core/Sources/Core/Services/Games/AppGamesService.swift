import Foundation
import Combine
import API

public typealias AppGamesServiceErrorResponse = RequestErrorResponse<AppGamesServiceError>

public enum AppGamesServiceError: HashableError {
	case network(underlyingError: String)
}

extension AppGamesServiceError {
	init(with error: Error) {
		self = .network(underlyingError: error.localizedDescription)
	}
}

public protocol AppGamesService {
	func games() -> AnyPublisher<[AppModels.Game], AppGamesServiceErrorResponse>
	func games(for filter: AppModels.GameFilter) -> AnyPublisher<[AppModels.Game], AppGamesServiceErrorResponse>
	func game(for id: Int) -> AnyPublisher<AppModels.Game, AppGamesServiceErrorResponse>
	func search(query: String, fetchingMore: Bool) -> AnyPublisher<[AppModels.Game], AppGamesServiceErrorResponse>
	
	func games(cursor: Cursor) async throws -> DefaultGamesModel
	func game(for id: Int) async throws -> AppModels.Game
	func findGames(searchTerm: String, nextCursor: Cursor) async throws -> DefaultGamesModel
	func games(for filter: AppModels.GameFilter) async throws -> [AppModels.Game]
}
