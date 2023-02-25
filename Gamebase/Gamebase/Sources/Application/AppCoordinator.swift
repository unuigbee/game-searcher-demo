import Combine
import Foundation
import UIKit
import GamebaseFacade
import GamebaseUI
import GBFeatures
import GBFoundation

final class AppCoordinator: Coordinator<Void> {
	private unowned let provider: Providing
	private weak var scene: UIWindowScene?
	private var window: UIWindow?
	private unowned let driver: AppDriver
	
	public init(
		driver: AppDriver,
		scene: UIScene,
		provider: Providing
	) {
		self.provider = provider
		self.driver = driver
		self.scene = scene as? UIWindowScene
		self.window = (scene as? UIWindowScene).flatMap(UIWindow.init)
		window?.makeKeyAndVisible()
		
		super.init()
	}
	
	override func start() -> AnyPublisher<Void, Never> {
		openGamesListScreen()
		return .never()
	}
	
	private func openGamesListScreen() {
		let feature = provider.features.gamesList
		let navigationController = UINavigationController()
		window?.rootViewController = navigationController
		
		let coordinator = feature.makeCoordinator(
			with: navigationController,
			viewData: .init()
		)
		
		coordinate(to: coordinator)
			.sink()
			.store(in: &cancellables)
	}
}
