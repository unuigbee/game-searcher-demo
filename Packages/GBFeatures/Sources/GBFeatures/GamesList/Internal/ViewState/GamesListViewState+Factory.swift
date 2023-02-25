import Core
import UIKit
import Foundation
import GBFoundation

extension GamesListViewState {
	static var initial: Self {
		.init(
			title: "Games",
			recommended: [],
			sections: [],
			fetchState: .empty,
			isDetailPresented: false
		)
	}

	func updateBySetting(image: UIImage, for item: GameItem) -> Self {
		let updated: [GameItem] = recommended
			.map { game in
				guard game.id == item.id else { return game }
				
				return GameItem(
					id: game.id,
					title: game.title,
					coverURL: game.coverURL,
					image: image
				)
			}

		return with { $0.recommended = updated }
	}
}

// MARK: - FetchState

extension GamesListViewState {
	func updatingFetchState(to state: FetchState) -> Self {
		with { $0.fetchState = state }
	}
}

// MARK: - Games

extension GamesListViewState {
	func gamesLoading() -> Self {
		with { $0.fetchState = .games(.loading) }
	}
	
	func gamesSuccess(
		with model: GamesListServiceModel,
		cache: AnyCacheOf<ImageCache>,
		formatter: ImageURLFormatting
	) -> Self {
		let updated = model.games.map {
			GameItem(
				$0,
				cache: cache,
				formatter: formatter
			)
		}
		
		return with {
			$0.fetchState = .games(.success)
			$0.recommended = updated
		}
	}
	
	func gamesError(_ error: AppGamesServiceErrorResponse) -> Self {
		with { $0.fetchState = .games(.error(error)) }
	}
}
