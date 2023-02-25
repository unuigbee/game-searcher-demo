import Foundation
import UIKit
import SwiftUI
import Combine
import GBFoundation

final class SceneDelegate: UIResponder, UIWindowSceneDelegate, CombineCancellableHolder {
	var appDelegate: AppDelegate! { UIApplication.shared.delegate as? AppDelegate }
	var appCoordinator: AppCoordinator!
	
	var window: UIWindow?
	weak var windowScene: UIWindowScene?

	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		appCoordinator = AppCoordinator(
			driver: appDelegate.appDriver,
			scene: scene,
			provider: appDelegate.provider
		)
		
		appCoordinator.start()
			.sink()
			.store(in: &cancellables)
	}
}
