import Combine

@MainActor public protocol TabBarEvents {
	var doubleTap: AnyPublisher<TabBarItem.Tab, Never> { get }
	var singleTap: AnyPublisher<TabBarItem.Tab, Never> { get }

	func distinctTap(for tabBarItem: TabBarItem.Tab) -> AnyPublisher<Void, Never>
}
