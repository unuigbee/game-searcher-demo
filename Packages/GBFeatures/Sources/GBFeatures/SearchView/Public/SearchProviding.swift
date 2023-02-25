import UIKit
import GamebaseUI
import Combine

@MainActor public protocol SearchProviding {
	var subRoutes: SearchProvidingSubRoutes { get }
	
	func makeCoordinator(
		with navigationViewController: UINavigationController,
		viewData: SearchViewData
	) -> Coordinator<Void>
	
	func makeCoordinator(
		with viewModel: SearchViewModel,
		gameDetailViewModel: GameDetailViewModel,
		viewData: SearchViewData,
		onTransition: AnyPublisher<ViewTransitionData, Never>
	) -> Coordinator<Void>
}

