import Foundation

public extension AppModels.InvolvedCompany.Company {
	struct Logo: Hashable {
		public let id: Int
		public let image_id: String
		public let game: Int?
		public let url: String
	}
}
