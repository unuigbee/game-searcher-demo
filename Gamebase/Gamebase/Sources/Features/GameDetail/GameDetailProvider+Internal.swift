import Foundation
import GBFeatures
import GamebaseFacade
import GBFoundation
import GamebaseUI

extension GameDetailProviding {
	func makeView(viewModel: GameDetailViewModel) -> GameDetailView {
		GameDetailView(viewModel: viewModel)
	}
	
	func makeViewModel(
		service: GameDetailService,
		viewData: GameDetailViewData
	) -> GameDetailViewModel {
		GameDetailViewModel(
			service: service,
			viewData: viewData,
			cache: GameDetailCache(
				image: .shared,
				game: .shared
			)
		)
	}
	
	func makeService(using core: CoreProviding) -> GameDetailService {
		GameDetailService(
			gamesService: core.games,
			imageLoaderService: core.image,
			cache: .shared
		)
	}
}
