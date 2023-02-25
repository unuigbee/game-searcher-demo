import Foundation
import UIKit
import GamebaseUI

@MainActor public protocol TabBarProviding {
	func makeCoordinator(
		window: UIWindow,
		viewData: TabBarViewData
	) -> Coordinator<Void>
}
