import API
import Combine
import GBFoundation

public final class DefaultAppGamesService: AppGamesService {
	private let remoteService: GamesService
	
	public init(remoteService: GamesService) {
		self.remoteService = remoteService
	}
	
	// MARK: - Async/Await
	
	public func games(cursor: Cursor) async throws -> DefaultGamesModel {
		try await mapThrow {
			let games = try await remoteService.games(nextCursor: cursor.next)
			return DefaultGamesModel(
				games,
				nextCursor: cursor.newCursor(
					fromPrevious: cursor,
					count: games.count
				)
			)
		}
	}
	
	public func game(for id: Int) async throws -> AppModels.Game {
		try await mapThrow {
			let game = try await remoteService.game(for: id)
			return AppModels.Game.init(with: game)
		}
	}
	
	public func findGames(searchTerm: String, nextCursor: Cursor) async throws -> DefaultGamesModel {
		try await mapThrow {
			let games = try await remoteService.findGames(
				searchTerm: searchTerm,
				nextCursor: nextCursor.next
			)
			return DefaultGamesModel(
				games,
				nextCursor: nextCursor.newCursor(
					fromPrevious: nextCursor,
					count: games.count
				)
			)
		}
	}
	
	public func games(for filter: AppModels.GameFilter) async throws -> [AppModels.Game] {
		try await mapThrow {
			let games = try await remoteService.games(for: GameFilter(filter))
			return games.map(AppModels.Game.init)
		}
	}
	
	// MARK: - Combine
	
	public func games() -> AnyPublisher<[AppModels.Game], AppGamesServiceErrorResponse> {
		remoteService.games()
			.map({ $0.map(AppModels.Game.init) })
			.mapError(AppGamesServiceError.init)
			.mapError(AppGamesServiceErrorResponse.specific(error:))
			.eraseToAnyPublisher()
	}
	
	public func games(for filter: AppModels.GameFilter) -> AnyPublisher<[AppModels.Game], AppGamesServiceErrorResponse> {
		remoteService.games(for: GameFilter.init(filter))
			.map({ $0.map(AppModels.Game.init) })
			.mapError(AppGamesServiceError.init)
			.mapError(AppGamesServiceErrorResponse.specific(error:))
			.eraseToAnyPublisher()
	}
	
	public func game(for id: Int) -> AnyPublisher<AppModels.Game, AppGamesServiceErrorResponse> {
		remoteService.game(for: id)
			.map(AppModels.Game.init)
			.mapError(AppGamesServiceError.init)
			.mapError(AppGamesServiceErrorResponse.specific(error:))
			.eraseToAnyPublisher()
	}
	
	public func search(query: String, fetchingMore: Bool) -> AnyPublisher<[AppModels.Game], AppGamesServiceErrorResponse> {
		remoteService.search(query: query, fetchingMore: fetchingMore)
			.map({ $0.map(AppModels.Game.init) })
			.mapError(AppGamesServiceError.init)
			.mapError(AppGamesServiceErrorResponse.specific(error:))
			.eraseToAnyPublisher()
	}
	
	private func mapThrow<T>(block: () async throws -> T) async throws -> T {
		do {
			let result = try await block()
			return result
		} catch let error as APIError {
			throw AppGamesServiceErrorResponse.error(fromAPIError: error)
		} catch {
			throw error
		}
	}
}
