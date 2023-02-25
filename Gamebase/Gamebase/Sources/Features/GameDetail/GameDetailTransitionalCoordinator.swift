import Combine
import GBFeatures
import GamebaseUI
import GamebaseFacade
import Foundation

final class GameDetailTransitionalCoordinator: TransitionCoordinator<Void> {
	private unowned let provider: Providing
	private weak var viewModel: GameDetailViewModel?
	private let viewData: GameDetailViewData
	
	var onTransition: AnyPublisher<ViewTransitionData, Never>

	private let result = PassthroughSubject<Void, Never>()
	
	init(
		provider: Providing,
		viewData: GameDetailViewData,
		viewModel: GameDetailViewModel,
		onTransition: AnyPublisher<ViewTransitionData, Never>
	) {
		self.viewModel = viewModel
		self.onTransition = onTransition
		self.provider = provider
		self.viewData = viewData
		
		super.init()
		setupObservers()
	}
	
	override func start() -> AnyPublisher<Void, Never> {
		loadGameDetail()
		return result.eraseToAnyPublisher()
	}
	
	private func loadGameDetail() {
		viewModel?.onLoad.send(viewData)
	}
	
	private func setupObservers() {
		guard let viewModel else { return }
		
		setupTransition(
			linking: onTransition,
			to: viewModel.didReceiveTransition
		)
		
		viewModel.onDismiss
			.subscribe(result)
			.store(in: &cancellables)
	}
}

