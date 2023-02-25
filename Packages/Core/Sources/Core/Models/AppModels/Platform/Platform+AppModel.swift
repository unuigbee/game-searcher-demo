import Foundation
import GBFoundation

public extension AppModels {
	struct Platform: Hashable, Then {
		public let id: Int
		public internal(set) var name: String
		public internal(set) var alternativeName: String?
		public internal(set) var abbreviation: String?
		public internal(set) var category: Category?
		public internal(set) var generation: Int?
		public internal(set) var logoId: Int?
		public internal(set) var logo: Logo?
	}
}
