import UIKit
import Combine
import GamebaseUI
import GamebaseFacade
import GBFeatures

final class SearchCoordinator: Coordinator<Void> {
	unowned let provider: Providing
	private unowned let navigationController: UINavigationController
	private let viewData: SearchViewData
	
	private let result = PassthroughSubject<Void, Never>()
	
	init(
		provider: Providing,
		navigationController: UINavigationController,
		viewData: SearchViewData
	) {
		self.provider = provider
		self.navigationController = navigationController
		self.viewData = viewData
		
		super.init()
	}
	
	override func start() -> AnyPublisher<Void, Never> {
		return result.eraseToAnyPublisher()
	}
}
