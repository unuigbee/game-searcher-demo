import Foundation
import GBFoundation

public extension AppModels {
	struct Genre: Hashable, Then {
		public let id: Int
		public internal(set) var name: String
	}
}
