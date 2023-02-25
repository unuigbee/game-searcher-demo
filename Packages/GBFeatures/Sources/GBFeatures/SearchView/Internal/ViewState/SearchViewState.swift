import Foundation
import SwiftUI
import GamebaseUI
import GBFoundation
import Core

struct SearchViewState: Hashable, Then {
	var searchTerm: String
	var fetchState: FetchState
	var isDetailPresented: Bool
	var items: [GameItem]
	var searchTags: [SearchTag]
	var hasMoreResults: Bool
	var isLoadingMore: Bool
	var transitionData: TransitionData
}

extension SearchViewState {
	var canLoadMore: Bool {
		hasItems && fetchState.isLoading == false && hasMoreResults
	}
	
	var hasItems: Bool {
		items.isEmpty == false
	}
	
	var isSearchEmpty: Bool {
		searchTerm.isEmpty
	}
	
	var recentSearches: [SearchTag] {
		searchTags
	}
	
	var canShowRecentSearches: Bool {
		recentSearches.isEmpty == false && hasItems == false
	}
	
	var isSearching: Bool {
		fetchState.isLoading && isLoadingMore == false
	}
}

extension SearchViewState {
	enum FetchState: Hashable {
		case empty
		case search(GenericRequestState)
	}
}

extension SearchViewState.FetchState {
	var errorResponse: GenericRequestErrorResponse? {
		switch self {
		case let .search(requestState):
			return requestState.requestError
		case .empty:
			return nil
		}
	}

	var isLoading: Bool {
		switch self {
		case let .search(requestState):
			return requestState == .loading
		case .empty:
			return false
		}
	}
}

extension SearchViewState {
	struct GameItem: Hashable, Identifiable {
		let id: Int
		let title: String
		let coverURL: URL?
		var image: UIImage?
	}
}

extension SearchViewState.GameItem {
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

extension SearchViewState.GameItem {
	static func url(fromCover cover: String?, formatter: ImageURLFormatting) -> URL? {
		cover.flatMap({ formatter.formattedImageURL(url: $0, for: .screenShotMedium)} )
	}
}
	
extension SearchViewState {
	struct TransitionData: Then, Hashable {
		let safeArea: EdgeInsets
		let sourceFrame: CGRect
		var animationProgress: Double
		
		init(
			animationProgress: Double,
			safeArea: EdgeInsets,
			sourceFrame: CGRect
		) {
			self.animationProgress = animationProgress
			self.safeArea = safeArea
			self.sourceFrame = sourceFrame
		}
	}
}

extension SearchViewState.TransitionData {
	init(data: ViewTransitionData) {
		self.animationProgress = data.animatableData
		self.sourceFrame = data.sourceViewFrame
		self.safeArea = data.safeArea
	}
}

extension SearchViewState.TransitionData {
	static let empty: Self = .init(
		animationProgress: .zero,
		safeArea: .zero,
		sourceFrame: .zero
	)
}

extension SearchViewState {
	struct SearchTag: Identifiable, Hashable {
		let id: UUID
		let keyword: String
		
		init?(keyword: String) {
			guard keyword.isEmpty == false else {
				return nil
			}
			self.id = UUID()
			self.keyword = keyword.capitalizingFirstLetter()
		}
	}
}
