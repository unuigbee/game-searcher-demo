import SwiftUI
import Combine
import GBFeatures
import GamebaseFacade
import GamebaseUI

final class GameListCoordinator: TransitionCoordinator<Void> {
	unowned let provider: Providing
	private unowned let navigationController: UINavigationController
	private let viewData: GamesListViewData
	
	private let result = PassthroughSubject<Void, Never>()
	
	init(
		provider: Providing,
		navigationController: UINavigationController,
		viewData: GamesListViewData
	) {
		self.provider = provider
		self.navigationController = navigationController
		self.viewData = viewData
		
		super.init()
	}
	
	override func start() -> AnyPublisher<Void, Never> {
		let viewController = makeViewController()
		navigationController.isNavigationBarHidden = true
		navigationController.setViewControllers([viewController], animated: false)

		return result.eraseToAnyPublisher()
	}
	
	// MARK: - Parent View
	
	private func makeViewController() -> UIViewController {
		let feature = provider.features.gamesList
		let service = feature.makeService(using: provider.core)
		let viewData = feature.makeViewData()
		let formatter = feature.makeFormatter()
		let viewModel = feature.makeViewModel(
			service: service,
			viewData: viewData,
			formatter: formatter
		)
		
		let view = feature.makeView(
			viewModel: viewModel,
			detailView: makeGameDetailView(whileObserving: viewModel),
			searchView: makeSearchView(whileObserving: viewModel)
		)
		
		let viewController = UIHostingController(rootView: view)
		
		return viewController
	}
	
	// MARK: - Sub Route: `GameDetail`
	
	private func makeGameDetailView(
		whileObserving gameListViewModel: GamesListViewModel
	) -> GameDetailView {
		let feature = provider.features.gamesList.subRoutes.gameDetail
		let service = feature.makeService(using: provider.core)
		let viewModel = feature.makeViewModel(
			service: service,
			viewData: .init(entity: nil, presentation: .custom)
		)

		setupGameDetailCrossViewModelObservers(
			viewModel: viewModel,
			gameListViewModel: gameListViewModel
		)
		
		let view = feature.makeView(viewModel: viewModel)
		
		return view
	}
	
	// MARK: - Sub Route:`Search`
	
	private func makeSearchView(
		whileObserving gameListViewModel: GamesListViewModel
	) -> SearchView<GameDetailView> {
		let feature = provider.features.gamesList.subRoutes.search
		let service = feature.makeService(using: provider.core)
		let userPreferences = feature.makeUserPreferences(using: provider.storage)
		let viewModel = feature.makeViewModel(
			service: service,
			viewData: .init(),
			userPreferences: userPreferences
		)
		
		let detailFeature = feature.subRoutes.gameDetail
		let detailService = detailFeature.makeService(using: provider.core)
		let detailViewModel = detailFeature.makeViewModel(
			service: detailService,
			viewData: .init(entity: nil, presentation: .custom)
		)
		let detailView = detailFeature.makeView(viewModel: detailViewModel)
		
		setupSearchCrossViewModelObservers(
			viewModel: viewModel,
			gameListViewModel: gameListViewModel,
			gameDetailViewModel: detailViewModel
		)
		
		let view = feature.makeView(
			viewModel: viewModel,
			detailView: detailView
		)
		
		return view
	}
	
	private func setupSearchCrossViewModelObservers(
		viewModel: SearchViewModel,
		gameListViewModel: GamesListViewModel,
		gameDetailViewModel: GameDetailViewModel
	) {
		gameListViewModel.onOpenSearch
			.flatMap(weak: self) { this, _ in
				this.openSearch(
					viewData: .init(),
					viewModel: viewModel,
					detailViewModel: gameDetailViewModel,
					onTransition: gameListViewModel.onTransition
				)
			}
			.subscribe(gameListViewModel.didDismiss)
			.store(in: &cancellables)
	}
	
	private func setupGameDetailCrossViewModelObservers(
		viewModel: GameDetailViewModel,
		gameListViewModel: GamesListViewModel
	) {
		setupTransition(
			linking: gameListViewModel.onTransition,
			to: viewModel.didReceiveTransition
		)
		
		gameListViewModel.onOpenGameDetail
			.flatMap(weak: self) { this, viewData in
				this.openGameDetail(
					viewData: viewData,
					viewModel: viewModel,
					onTransition: gameListViewModel.onTransition
				)
			}
			.subscribe(gameListViewModel.didDismiss)
			.store(in: &cancellables)
	}
}

// MARK: Open

extension GameListCoordinator {
	private func openSearch(
		viewData: SearchViewData,
		viewModel: SearchViewModel,
		detailViewModel: GameDetailViewModel,
		onTransition: AnyPublisher<ViewTransitionData, Never>
	) -> AnyPublisher<Void, Never> {
		let coordinator = provider.features.search.makeCoordinator(
			with: viewModel,
			gameDetailViewModel: detailViewModel,
			viewData: viewData,
			onTransition: onTransition
		)
		return coordinate(to: coordinator)
	}
	
	private func openGameDetail(
		viewData: GameDetailViewData,
		viewModel: GameDetailViewModel,
		onTransition: AnyPublisher<ViewTransitionData, Never>
	) -> AnyPublisher<Void, Never> {
		let coordinator = provider.features.gameDetail.makeCoordinator(
			with: viewModel,
			viewData: viewData,
			onTransition: onTransition
		)
		return coordinate(to: coordinator)
	}
}
