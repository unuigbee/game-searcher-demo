import Foundation
import UIKit
import GBFoundation
import Core

@MainActor
public final class SearchViewService {
	// MARK: - Dependecies
	
	private let gamesService: AppGamesService
	private let imageLoaderService: AppImageLoaderService
	private let cache: AnyCache<Int, AppModels.Game>
	
	// MARK: - Props
	
	private var model: SearchViewServiceModel = .empty()
	
	// MARK: - Init
	
	public init(
		gamesService: AppGamesService,
		imageLoaderService: AppImageLoaderService,
		cache: AnyCache<Int, AppModels.Game>
	) {
		self.gamesService = gamesService
		self.imageLoaderService = imageLoaderService
		self.cache = cache
	}
	
	func find(by searchTerm: String) async throws -> SearchViewServiceModel {
		let data = try await gamesService.findGames(
			searchTerm: searchTerm,
			nextCursor: .initial
		)
		
		model = model.settingSearchResults(to: data.games, cursor: data.nextCursor)
		updateCache(withGames: data.games)
		
		return model
	}
	
	func findMore(of searchTerm: String) async throws -> SearchViewServiceModel {
		let data = try await gamesService.findGames(
			searchTerm: searchTerm,
			nextCursor: model.cursor
		)
		
		model = model.updatingSearchResults(
			with: data.games,
			cursor: data.nextCursor,
			hasMoreResults: data.games.isEmpty == false
		)
		
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
}

struct SearchViewServiceModel: Hashable, Then {
	var games: [AppModels.Game]
	var cursor: Cursor
	var hasMoreResults: Bool
}

extension SearchViewServiceModel {
	static func empty() -> Self {
		.init(games: [], cursor: .initial, hasMoreResults: true)
	}
}

extension SearchViewServiceModel {
	func settingSearchResults(to games: [AppModels.Game], cursor: Cursor) -> Self {
		with {
			$0.games = games
			$0.cursor = cursor
			$0.hasMoreResults = true
		}
	}
	
	func updatingSearchResults(
		with games: [AppModels.Game],
		cursor: Cursor,
		hasMoreResults: Bool
	) -> Self {
		with {
			$0.games = $0.games + games
			$0.cursor = cursor
			$0.hasMoreResults = hasMoreResults
		}
	}
}
