import Foundation
import Core
import Combine
import SwiftUI
import GBFeatures
import GamebaseFacade
import GamebaseUI
import GBFoundation

final class GamesListProvider: GamesListProviding {
	// MARK: - Props
	private(set) lazy var subRoutes: GamesListProvidingSubRoutes = makeGameListSubRoutes()
	
	unowned let provider: Providing
	
	// MARK: - Init
	
	init(provider: Providing) {
		self.provider = provider
	}
	
	// MARK: - GameListProviding
	func makeCoordinator(
		with navigationViewController: UINavigationController,
		viewData: GamesListViewData
	) -> Coordinator<Void> {
		GameListCoordinator(
			provider: provider,
			navigationController: navigationViewController,
			viewData: viewData
		)
	}
	
	func makeGameListSubRoutes() -> GamesListProvidingSubRoutes {
		GamesListProvidingSubRoutes(
			gameDetail: GameDetailProvider(provider: provider),
			search: SearchProvider(provider: provider)
		)
	}
}

// WIP/Experiemental
class AppRouter: Router<Void> {
	// MARK: - Props
	unowned let provider: Providing
	unowned let appDriver: AppDriver
	
	// MARK: - Init
	public init(provider: Providing, appDriver: AppDriver) {
		self.provider = provider
		self.appDriver = appDriver
		super.init()
		
		setUpBindings()
	}
	
	override func start() -> AnyPublisher<Void, Never> {
		return .never()
	}
	
	private func setUpBindings() {
		start()
			.sink()
			.store(in: &cancellables)
	}
}
