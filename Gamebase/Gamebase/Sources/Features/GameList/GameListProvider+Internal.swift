import Foundation
import GBFeatures
import GamebaseFacade
import GBFoundation
import GamebaseUI

extension GamesListProviding {
	func makeViewModel(
		service: GamesListService,
		viewData: GamesListViewData,
		formatter: ImageURLFormatting
	) -> GamesListViewModel {
		GamesListViewModel(
			service: service,
			viewData: viewData,
			formatter: formatter,
			imageCache: .shared
		)
	}
	
	func makeService(using core: CoreProviding) -> GamesListService {
		GamesListService(
			gamesService: core.games,
			imageLoaderService: core.image,
			cache: .shared
		)
	}
	
	func makeViewData() -> GamesListViewData {
		GamesListViewData()
	}
	
	func makeFormatter() -> ImageURLFormatting {
		ImageURLFormatter()
	}
	
	func makeView(
		viewModel: GamesListViewModel,
		detailView: GameDetailView,
		searchView: SearchView<GameDetailView>
	) -> GameListView<GameDetailView, SearchView<GameDetailView>> {
		GameListView(
			viewModel: viewModel,
			detailView: detailView,
			searchView: searchView
		)
	}
}
