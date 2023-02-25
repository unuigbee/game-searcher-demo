import Foundation
import GamebaseUI
import UIKit

public typealias ViewDeeplinkNavigationCoordinator = Coordinator<Void> & ViewDeeplinkNavigator

@MainActor public protocol ViewDeeplinkProviding: AnyProvider {
	func makeCoordinator(rootViewController: UIViewController) -> ViewDeeplinkNavigationCoordinator
}
