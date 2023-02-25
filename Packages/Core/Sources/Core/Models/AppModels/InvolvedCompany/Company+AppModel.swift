import Foundation
import GBFoundation

public extension AppModels.InvolvedCompany {
	struct Company: Hashable, Then {
		public let id: Int
		public internal(set) var name: String
		public internal(set) var description: String?
		public internal(set) var developed: [Int]?
		public internal(set) var logo: Int?
	}
}

