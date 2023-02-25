import Foundation
import UIKit
import GBFoundation
import Core

extension SearchViewState {
	static var initial: Self = .init(
		searchTerm: "",
		fetchState: .empty,
		isDetailPresented: false,
		items: [],
		searchTags: [],
		hasMoreResults: false,
		isLoadingMore: false,
		transitionData: .empty
	)
	
	func updateBySetting(image: UIImage, for item: GameItem) -> Self {
		let updated: [GameItem] = items
			.map { game in
				guard game.id == item.id else { return game }
				
				return GameItem(
					id: game.id,
					title: game.title,
					coverURL: game.coverURL,
					image: image
				)
			}

		return with { $0.items = updated }
	}
	
	// MARK: - Fetch State
	
	func updateFetchState(to state: FetchState) -> Self {
		with { $0.fetchState = state }
	}
	
	// MARK: - Search Results
	
	func searchResultsLoading(isLoadingMore: Bool) -> Self {
		with {
			$0.fetchState = .search(.loading)
			$0.isLoadingMore = isLoadingMore
		}
	}
	
	func searchResultsSuccess(
		with model: SearchViewServiceModel,
		searchTerm: String,
		cache: AnyCache<URL, UIImage>
	) -> Self {
		with {
			$0.fetchState = model.games.isEmpty ? .empty : .search(.success)
			$0.items = model.games
				.removingDuplicates()
				.map { GameItem($0, cache: cache, formatter: ImageURLFormatter()) }
			$0.searchTags = updatedSearchTags(from: searchTerm)
			$0.hasMoreResults = model.hasMoreResults
		}
	}
	
	func searchResultsError(_ error: GenericRequestErrorResponse) -> Self {
		with { $0.fetchState = .search(.error(error)) }
	}
	
	func clearingSearchResults() -> Self {
		with {
			$0.searchTerm = ""
			$0.fetchState = .empty
			$0.items = []
		}
	}
	
	func resettingSearchResults() -> Self {
		with {
			$0.fetchState = .empty
			$0.items = []
		}
	}
	
	// MARK: - Search Tags
	
	func updateBySettingSearchTags(_ tags: [String]) -> Self {
		let lowerCasedTags = tags.map { $0.lowercased() }
		let tags = lowerCasedTags.removingDuplicates()
		return with { $0.searchTags = tags.compactMap(SearchTag.init) }
	}
	
	func updateBySettingSearchTerm(to tag: String) -> Self {
		with { $0.searchTerm = tag } 
	}
	
	func updateByClearingSearchTag(by id: UUID) -> Self {
		let updatedSearchTags = searchTags.filter { $0.id != id }
		return with { $0.searchTags = updatedSearchTags }
	}
	
	private func updatedSearchTags(from searchTerm: String, limit: Int = 3) -> [SearchTag] {
		guard let newTag = SearchTag(keyword: searchTerm) else {
			return searchTags
		}
		
		guard searchTags.contains(where: { $0.keyword == newTag.keyword }) == false else {
			return searchTags
		}
		
		let updatedTags = [newTag] + searchTags
		
		return Array(updatedTags.prefix(3))
	}
}

