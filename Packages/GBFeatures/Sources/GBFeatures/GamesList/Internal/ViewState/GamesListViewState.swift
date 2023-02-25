import Foundation
import GBFoundation
import Core
import UIKit

typealias GamesListRequestState = RequestState<AppGamesServiceError>

struct GamesListViewState: Hashable, Then {
	var title: String
	var recommended: [GameItem]
	var sections: [Section]
	var fetchState: FetchState
	var isDetailPresented: Bool
}

extension GamesListViewState {
	var hasGames: Bool {
		recommended.isEmpty == false
	}
	
	var canLoadMore: Bool {
		hasGames && fetchState.isLoading == false
	}
	
	var sectionItems: [GameItem] {
		sections.flatMap(\.items)
	}
}

extension GamesListViewState.FetchState {
	var error: AppGamesServiceErrorResponse? {
		switch self {
		case let .games(requestState):
			return requestState.requestError
		case .empty:
			return nil
		}
	}
	
	var isLoading: Bool {
		switch self {
		case let .games(requestState):
			return requestState == .loading
		case .empty:
			return false
		}
	}
}

extension GamesListViewState.GameItem {
	init(
		_ game: AppModels.Game,
		cache: AnyCacheOf<ImageCache>,
		formatter: ImageURLFormatting
	) {
		self.id = game.id
		self.title = game.title
		let url = Self.url(fromCover: game.cover?.url, formatter: formatter)
		self.coverURL = url
		self.image = url.flatMap { cache.item(for: $0) }
	}
}

extension GamesListViewState.GameItem {
	static func url(fromCover cover: String?, formatter: ImageURLFormatting) -> URL? {
		cover.flatMap({ formatter.formattedImageURL(url: $0, for: .screenShotMedium)} )
	}
}

extension GamesListViewState {
	struct GameItem: Hashable, Identifiable {
		let id: Int
		let title: String
		let coverURL: URL?
		var image: UIImage?
	}
	
	struct Filter: Hashable, Identifiable {
		let id: Int
		let name: String
	}
}

extension GamesListViewState {
	enum FetchState: Hashable {
		case empty
		case games(GamesListRequestState)
	}
}

extension GamesListViewState {
	enum SectionType: Hashable {
		case topRated([GameItem])
		case fighting([GameItem])
		case shooter([GameItem])
		case moba([GameItem])
		case arcade([GameItem])
		case indie([GameItem])
		case sport([GameItem])
		case platform([GameItem])
	}

	struct Section: Hashable, Equatable {
		let title: String?
		let sectionType: SectionType

		init(title: String?, sectionType: SectionType) {
			self.title = title
			self.sectionType = sectionType
		}
	}
}

extension GamesListViewState.Section: Identifiable {
	var id: String {
		switch sectionType {
		case .topRated: return "topRated.section"
		case .fighting: return "fighting.section"
		case .shooter: return "shooter.section"
		case .moba: return "moba.section"
		case .arcade: return "arcade.section"
		case .indie: return "indie.section"
		case .sport: return "sport.section"
		case .platform: return "platform.section"
		}
	}
	
	var items: [GamesListViewState.GameItem] {
		switch sectionType {
		case let .topRated(items): return items
		case let .fighting(items): return items
		case let .shooter(items): return items
		case let .moba(items): return items
		case let .arcade(items): return items
		case let .indie(items): return items
		case let .sport(items): return items
		case let .platform(items): return items
		}
	}
}
