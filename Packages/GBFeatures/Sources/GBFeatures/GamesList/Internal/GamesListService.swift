import Core
import Combine
import GBFoundation
import Foundation
import UIKit

@MainActor
public final class GamesListService {
	private let gamesService: AppGamesService
	private let imageLoaderService: AppImageLoaderService
	private let cache: AnyCache<Int, AppModels.Game>
	
	private(set) var model: GamesListServiceModel = .init()
	
	public init(
		gamesService: AppGamesService,
		imageLoaderService: AppImageLoaderService,
		cache: AnyCache<Int, AppModels.Game>
	) {
		self.gamesService = gamesService
		self.imageLoaderService = imageLoaderService
		self.cache = cache
	}
	
	// MARK: - Async/Await
	
	func games() async throws -> GamesListServiceModel {
		let data = try await gamesService.games(cursor: model.cursor)
		model = model.update(withGames: data.games, cursor: data.nextCursor)
		updateCache(withGames: data.games)
		return model
	}
	
	func loadImage(for url: URL?) async -> UIImage? {
		guard let url = url else { return nil }
		return await imageLoaderService.image(for: url)
	}
	
	private func updateCache(withGames games: [AppModels.Game]) {
		games.forEach { cache.insert($0, for: $0.id) }
	}
	
	// MARK: - Combine
	
	func recommendedGames() -> AnyPublisher<[AppModels.Game], AppGamesServiceErrorResponse> {
		gamesService.games()
			.cache(withTypeOf: cache)
			.eraseToAnyPublisher()
	}
		
	func loadImage(for url: URL?) -> AnyPublisher<UIImage?, Never> {
		guard let url else { return .just(nil) }
		return imageLoaderService.image(for: url)
	}
}

// MARK: - Service Model

struct GamesListServiceModel: Hashable, Then {
	var games: [AppModels.Game] = []
	var cursor: Cursor = .initial
}

extension GamesListServiceModel {
	func update(withGames games: [AppModels.Game], cursor: Cursor) -> Self {
		with {
			$0.games = $0.games + games
			$0.cursor = cursor
		}
	}
}
