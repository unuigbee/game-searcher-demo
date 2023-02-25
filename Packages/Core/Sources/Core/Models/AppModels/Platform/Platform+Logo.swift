import Foundation

public extension AppModels.Platform {
	struct Logo: Hashable {
		public let id: Int
		public let imageId: String
		public let game: Int?
		public let url: String

		public init(
			id: Int,
			imageId: String,
			game: Int?,
			url: String
		) {
			self.id = id
			self.imageId = imageId
			self.game = game
			self.url = url
		}
	}
}
