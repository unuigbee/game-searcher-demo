import Combine
import SwiftUI
import GBFeatures
import GamebaseFacade
import GamebaseUI

final class GameDetailProvider: GameDetailProviding {
	// MARK: - Props
	
	unowned let provider: Providing
	
	// MARK: - Init

	init(provider: Providing) {
		self.provider = provider
	}
	
	// MARK: - GameDetailProviding
	
	func makeCoordinator(
		with navigationViewController: UINavigationController,
		viewData: GameDetailViewData
	) -> Coordinator<Void> {
		GameDetailCoordinator(
			provider: provider,
			navigationController: navigationViewController,
			viewData: viewData
		)
	}
	
	func makeCoordinator(
		with viewModel: GameDetailViewModel,
		viewData: GameDetailViewData,
		onTransition: AnyPublisher<ViewTransitionData, Never>
	) -> Coordinator<Void> {
		GameDetailTransitionalCoordinator(
			provider: provider,
			viewData: viewData,
			viewModel: viewModel,
			onTransition: onTransition
		)
	}
}
