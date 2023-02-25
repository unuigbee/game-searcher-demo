import Foundation

public struct ViewDeeplinkData {
	public let type: NavigationType

	public init(type: ViewDeeplinkData.NavigationType) {
		self.type = type
	}
}

public extension ViewDeeplinkData {
	enum NavigationType {
		case notification//(VendorPushNotification)
		case urlDeeplink//(VendorURLDeeplink)
	}
}
