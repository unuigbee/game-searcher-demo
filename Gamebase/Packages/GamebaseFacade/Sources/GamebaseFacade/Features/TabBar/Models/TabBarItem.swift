public struct TabBarItem {
	public let tab: Tab
	public let imageName: String
	public let title: String
	
	public init(
		tab: Tab,
		imageName: String,
		title: String
	) {
		self.tab = tab
		self.imageName = imageName
		self.title = title
	}
	
	public enum Tab {
		case home
	}
}
