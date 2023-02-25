import GBFeatures
import GamebaseFacade
import Core

extension SearchProviding {
	func makeView(
		viewModel: SearchViewModel,
		detailView: GameDetailView
	) -> SearchView<GameDetailView> {
		.init(viewModel: viewModel, detailView: detailView)
	}
	
	func makeViewModel(
		service: SearchViewService,
		viewData: SearchViewData,
		userPreferences: some SearchUserPreferencesStoring
	) -> SearchViewModel {
		.init(
			viewData: viewData,
			service: service,
			cache: .shared,
			userPreferences: userPreferences
		)
	}
	
	func makeService(
		using core: some CoreProviding
	) -> SearchViewService {
		.init(
			gamesService: core.games,
			imageLoaderService: core.image,
			cache: .shared
		)
	}
	
	func makeUserPreferences(
		using storage: some StorageProviding
	) -> some SearchUserPreferencesStoring {
		DefaultSearchUserPreferencesStorage(
			userPreferencesStorage: storage.userPreferences
		)
	}
}
