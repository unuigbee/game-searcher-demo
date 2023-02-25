import Foundation
import Combine
import SwiftUI
import GBFeatures
import GamebaseUI
import GamebaseFacade

final class GameDetailCoordinator: Coordinator<Void> {
	unowned let provider: Providing
	private unowned let navigationController: UINavigationController
	private let viewData: GameDetailViewData
	
	private let result = PassthroughSubject<CoordinationResult, Never>()
	
	init(
		provider: Providing,
		navigationController: UINavigationController,
		viewData: GameDetailViewData
	) {
		self.provider = provider
		self.navigationController = navigationController
		self.viewData = viewData
		
		super.init()
	}
	
	override func start() -> AnyPublisher<Void, Never> {
		let viewController = makeViewController()
		navigationController.present(viewController, animated: true)

		return result.eraseToAnyPublisher()
	}
	
	private func makeViewController() -> UIViewController {
		let feature = provider.features.gameDetail
		let service = feature.makeService(using: provider.core)
		let viewModel = feature.makeViewModel(
			service: service,
			viewData: viewData
		)
		let view = feature.makeView(viewModel: viewModel)
		
		let viewController = UIHostingController(rootView: view)
		
		setupObservers(viewModel)
		
		return UINavigationController(rootViewController: viewController)
	}
	
	private func setupObservers(_ viewModel: GameDetailViewModel) {
		viewModel.onDismiss
			.sink { [weak self] _ in
				self?.navigationController.popViewController(animated: true)
				self?.result.send()
			}
			.store(in: &cancellables)
	}
}

