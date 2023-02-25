//
//  AppDelegate.swift
//  Gamebase
//
//  Created by Emmanuel Unuigbe on 01/09/2021.
//

import Foundation
import UIKit
import SwiftUI
import Combine

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	lazy var appDriver = makeAppDriver()
	let provider = Provider(application: .shared, bundle: .main)
	
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		return true
	}
	
	func application(
		_ application: UIApplication,
		configurationForConnecting connectingSceneSession: UISceneSession,
		options: UIScene.ConnectionOptions
	) -> UISceneConfiguration {
		UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}
	
	func application(
		_ application: UIApplication,
		didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
	) {}
	
	private func makeAppDriver() -> AppDriver {
		AppDriver(provider: provider)
	}
}
