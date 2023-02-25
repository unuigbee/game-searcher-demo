import Foundation

@MainActor public protocol TabBarTabItemSelecting {
	func setSelectedTab(
		_ tab: TabBarItem.Tab,
		popToRootViewController: Bool,
		animated: Bool
	)
}

