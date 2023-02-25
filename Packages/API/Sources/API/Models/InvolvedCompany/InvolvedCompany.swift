import Foundation

public struct InvolvedCompany: Codable {
	public let id: Int
	public let company: Company
	public let publisher: Bool
	public let developer: Bool
	public let supporting: Bool
	
	public init(
		id: Int,
		company: Company,
		publisher: Bool,
		developer: Bool,
		supporting: Bool
	) {
		self.id = id
		self.company = company
		self.publisher = publisher
		self.developer = developer
		self.supporting = supporting
	}
}
