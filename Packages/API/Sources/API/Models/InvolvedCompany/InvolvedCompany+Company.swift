import Foundation

public extension InvolvedCompany {
	struct Company: Codable, Identifiable {
		public let id: Int
		public let name: String
		public let description: String?
		public let developed: [Int]?
		public let logo: Int?

		public init(
			id: Int,
			name: String,
			description: String?,
			developed: [Int],
			logo: Int?
		) {
			self.id = id
			self.name = name
			self.description = description
			self.developed = developed
			self.logo = logo
		}
	}
}
