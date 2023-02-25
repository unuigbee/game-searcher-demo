import Foundation
import GBFoundation

public extension AppModels {
	struct Game: Identifiable, Hashable, Then {
		public let id: Int
		public internal(set) var title: String
		public internal(set) var description: String?
		public internal(set) var category: Category?
		public internal(set) var involvedCompanies: [InvolvedCompany]
		public internal(set) var cover: Cover?
		public internal(set) var screenshots: [Screenshot]
		public internal(set) var platforms: [Platform]
		
		public internal(set) var totalRating: Int?
		public internal(set) var totalRatingCount: Int
		public internal(set) var aggregatedRating: Int?
	}
}
