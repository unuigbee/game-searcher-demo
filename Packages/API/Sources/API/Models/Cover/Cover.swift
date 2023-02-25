import Foundation

public struct Cover: Codable {
	public let id: Int
	public let url: String

	public init(id: Int, url: String) {
		self.id = id
		self.url = url
	}
}
