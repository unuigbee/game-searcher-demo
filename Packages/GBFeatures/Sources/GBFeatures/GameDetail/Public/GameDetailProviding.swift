import Combine
import GamebaseUI
import SwiftUI

@MainActor public protocol GameDetailProviding {
	func makeCoordinator(
		with navigationViewController: UINavigationController,
		viewData: GameDetailViewData
	) -> Coordinator<Void>
	
	func makeCoordinator(
		with viewModel: GameDetailViewModel,
		viewData: GameDetailViewData,
		onTransition: AnyPublisher<ViewTransitionData, Never>
	) -> Coordinator<Void>
}
