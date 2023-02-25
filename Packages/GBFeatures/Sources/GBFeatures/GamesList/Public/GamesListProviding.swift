import Foundation
import UIKit
import GamebaseUI

@MainActor public protocol GamesListProviding {
	var subRoutes: GamesListProvidingSubRoutes { get }
	
	func makeCoordinator(
		with navigationViewController: UINavigationController,
		viewData: GamesListViewData
	) -> Coordinator<Void>
}
