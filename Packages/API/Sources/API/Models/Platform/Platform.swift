import Foundation

public struct Platform: Codable {
	public let id: Int
	public let name: String
	public let alternativeName: String?
	public let abbreviation: String?
	public let category: Category?
	public let generation: Int?
	public let logoId: Int?
	public let logo: Logo?
	
	enum CodingKeys: String, CodingKey {
		case id
		case name
		case category
		case generation
		case abbreviation
		case alternativeName = "alternative_name"
		case logoId = "platform_logo"
	}
	
	public init(
		id: Int,
		name: String,
		alternativeName: String?,
		abbreviation: String?,
		category: Category?,
		generation: Int?,
		logoId: Int?,
		logo: Logo?
	) {
		self.id = id
		self.name = name
		self.alternativeName = alternativeName
		self.category = category
		self.generation = generation
		self.logoId = logoId
		self.abbreviation = abbreviation
		self.logo = logo
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		id = try container.decode(Int.self, forKey: .id)
		name = try container.decode(String.self, forKey: .name)
		alternativeName = try? container.decode(String.self, forKey: .alternativeName)
		abbreviation = try? container.decode(String.self, forKey: .abbreviation)
		category = try? container.decode(Category.self, forKey: .category)
		generation = try? container.decode(Int.self, forKey: .generation)
		logoId = try? container.decode(Int.self, forKey: .logoId)
		logo = nil
	}
}

public extension Platform {
	enum Category: Int, Codable {
		case console = 1
		case arcade
		case platform
		case operating_system
		case portable_console
		case computer
	}
	
	struct Logo: Codable {
		public let id: Int
		public let imageId: String
		public let game: Int?
		public let url: String

		public init(
			id: Int,
			imageId: String,
			game: Int?,
			url: String
		) {
			self.id = id
			self.imageId = imageId
			self.game = game
			self.url = url
		}
	}
}
