import Foundation

public extension AppModels.Game {
	struct Cover: Hashable {
		public let id: Int
		public let url: String

		public init(id: Int, url: String) {
			self.id = id
			self.url = url
		}
	}
}

public extension AppModels.Game {
	struct Screenshot: Hashable {
		public let id: Int
		public let url: String

		public init(
			id: Int,
			url: String
		) {
			self.id = id
			self.url = url
		}
	}
}
