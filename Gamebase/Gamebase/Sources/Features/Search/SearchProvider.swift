import UIKit
import Combine
import GBFeatures
import GamebaseFacade
import GamebaseUI

final class SearchProvider: SearchProviding {
	private(set) lazy var subRoutes: SearchProvidingSubRoutes = makeGameListSubRoutes()
	
	unowned let provider: Providing
	
	// MARK: - Init
	init(provider: Providing) {
		self.provider = provider
	}
	
	func makeCoordinator(
		with navigationViewController: UINavigationController,
		viewData: SearchViewData
	) -> Coordinator<Void> {
		SearchCoordinator(
			provider: provider,
			navigationController: navigationViewController,
			viewData: viewData
		)
	}
	
	func makeCoordinator(
		with viewModel: SearchViewModel,
		gameDetailViewModel: GameDetailViewModel,
		viewData: SearchViewData,
		onTransition: AnyPublisher<ViewTransitionData, Never>
	) -> Coordinator<Void> {
		SearchTransitionalCoordinator(
			provider: provider,
			viewData: viewData,
			viewModel: viewModel,
			gameDetailViewModel: gameDetailViewModel,
			onTransition: onTransition
		)
	}
	
	func makeGameListSubRoutes() -> SearchProvidingSubRoutes {
		.init(gameDetail: GameDetailProvider(provider: provider))
	}
}
