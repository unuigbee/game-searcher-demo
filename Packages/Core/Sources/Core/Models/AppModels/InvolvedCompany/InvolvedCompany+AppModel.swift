import Foundation
import GBFoundation

public extension AppModels {
	struct InvolvedCompany: Hashable, Then {
		public let id: Int
		public internal(set) var company: AppModels.InvolvedCompany.Company
		public internal(set) var publisher: Bool
		public internal(set) var developer: Bool
		public internal(set) var supporting: Bool
	}
}
