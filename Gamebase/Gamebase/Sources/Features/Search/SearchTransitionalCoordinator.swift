import Combine
import GBFeatures
import GamebaseUI
import GamebaseFacade
import GBFoundation

final class SearchTransitionalCoordinator: TransitionCoordinator<Void> {
	private unowned let provider: Providing
	private let viewData: SearchViewData
	private weak var viewModel: SearchViewModel?
	private weak var gameDetailViewModel: GameDetailViewModel?
	
	private(set) var onTransition: AnyPublisher<ViewTransitionData, Never>
	
	private let result = PassthroughSubject<Void, Never>()
	
	init(
		provider: Providing,
		viewData: SearchViewData,
		viewModel: SearchViewModel,
		gameDetailViewModel: GameDetailViewModel,
		onTransition: AnyPublisher<ViewTransitionData, Never>
	) {
		self.provider = provider
		self.viewData = viewData
		self.viewModel = viewModel
		self.gameDetailViewModel = gameDetailViewModel
		self.onTransition = onTransition
		
		super.init()
		setupObservers()
	}
	
	override func start() -> AnyPublisher<Void, Never> {
		result.eraseToAnyPublisher()
	}
	
	private func setupObservers() {
		guard let searchViewModel = viewModel, let gameDetailViewModel else {
			return
		}
		
		setupTransition(
			linking: onTransition,
			to: searchViewModel.didReceiveTransition
		)
		
		setupTransition(
			linking: searchViewModel.onTransition,
			to: gameDetailViewModel.didReceiveTransition
		)
		
		searchViewModel.onDismiss
			.subscribe(result)
			.store(in: &cancellables)
		
		searchViewModel.onOpenGameDetail
			.flatMap(weak: self) { this, viewData in
				this.openGameDetail(
					viewData: viewData,
					viewModel: gameDetailViewModel,
					onTransition: searchViewModel.onTransition
				)
			}
			.subscribe(searchViewModel.handleGameDetailResult)
			.store(in: &cancellables)
	}
	
	// MARK: - Open
	
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
