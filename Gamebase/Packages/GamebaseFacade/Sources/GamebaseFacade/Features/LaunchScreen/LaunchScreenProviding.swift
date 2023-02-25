import Foundation
import GamebaseUI
import UIKit

@MainActor public protocol LaunchScreenProviding {
	func makeCoordinator(
		with navigationController: UINavigationController
	) -> Coordinator<Void>
}
