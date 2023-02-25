import Foundation

public struct SearchKeyword: Codable {
	private let date: Date
	public let name: String

	public init(name: String) {
		self.name = name
		self.date = Date()
	}
}
