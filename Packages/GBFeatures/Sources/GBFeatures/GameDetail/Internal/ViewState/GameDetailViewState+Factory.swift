import GBFoundation
import Core
import UIKit

extension GameDetailViewState {
	static let empty: Self = .init(
		item: nil,
		fetchState: .empty,
		transitionData: .empty,
		selectedScreenshots: .init(),
		isTransitioning: false
	)
	
	static func intial(
		viewData: GameDetailViewData,
		cache: some GameDetailCaching
	) -> Self {
		guard let id = viewData.entity?.id else {
			return .empty
		}
		
		let game = cache.game(for: id)
		let cover = game?.cover.flatMap {
			if let url = ImageURLFormatter.formattedImageURL(
				url: $0.url,
				for: .screenShotMedium
			) { return cache.image(for: url) }
			
			return nil
		}
		let item = GameItem(game, cover: cover)
		
		return .init(
			item: item,
			fetchState: item == nil ? .empty : .cached,
			transitionData: .empty,
			selectedScreenshots: .init(),
			isTransitioning: true
		)
	}
	
	func updatingFetchState(to state: FetchState) -> Self {
		with { $0.fetchState = state }
	}
	
	// MARK: - Item
	
	func updateItem(using cache: some GameDetailCaching, with id: Int) -> Self {
		let game = cache.game(for: id)
		let cover = game?.cover.flatMap {
			if let url = ImageURLFormatter.formattedImageURL(
				url: $0.url,
				for: .screenShotMedium
			) { return cache.image(for: url) }
			
			return nil
		}
		
		let item = GameItem(game, cover: cover)
		
		return with {
			$0.item = item
			$0.fetchState = item == nil ? .empty : .cached
		}
	}
	
	func itemSuccess(with model: GameDetailServiceModel) -> Self {
		with {
			$0.item = GameItem(model.game, cover: model.cover)
			$0.fetchState = model.game == nil ? .empty : .game(.success)
		}
	}
	
	func itemError(with error: AppGamesServiceErrorResponse) -> Self {
		with { $0.fetchState = .game(.error(error)) }
	}
	
	func itemLoading() -> Self {
		with { $0.fetchState = .game(.loading) }
	}
}
