import Foundation

public struct Game: Decodable {
	public let id: Int
	public let title: String
	public let description: String?
	public let category: Category?
	public let involvedCompanies: [InvolvedCompany]
	public let genres: [Genre]
	public let cover: Cover?
	public var screenshots: [Screenshot]
	public var platforms: [Platform]
	
	public let totalRating: Int?
	public let totalRatingCount: Int
	public let aggregatedRating: Int?
	
	enum CodingKeys: String, CodingKey {
		case id
		case title = "name"
		case description = "summary"
		case involvedCompanies = "involved_companies"
		case totalRating = "total_rating"
		case totalRatingCount = "total_rating_count"
		case aggregatedRating = "aggregated_rating"
		case cover
		case screenshots
		case platforms
		case genres
		case category
	}
	
	public init(
		id: Int,
		title: String,
		description: String?,
		cover: Cover?,
		category: Category?,
		involvedCompanies: [InvolvedCompany],
		genres: [Genre],
		platformIDs: [Int],
		screenshots: [Screenshot],
		platforms: [Platform],
		totalRating: Int?,
		totalRatingCount: Int,
		aggregatedRating: Int?
	) {
		self.id = id
		self.title = title
		self.description = description
		self.cover = cover
		self.category = category
		self.involvedCompanies = involvedCompanies
		self.genres = genres
		self.platforms = platforms
		self.screenshots = screenshots
		self.platforms = platforms
		self.totalRating = totalRating
		self.totalRatingCount = totalRatingCount
		self.aggregatedRating = aggregatedRating
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
	
		id = try container.decode(Int.self, forKey: .id)
		title = try container.decode(String.self, forKey: .title)
		description = try? container.decode(String.self, forKey: .description)
		category = (try? container.decode(Category.self, forKey: .category)) ?? .main_game
		involvedCompanies = (try? container.decode([InvolvedCompany].self, forKey: .involvedCompanies)) ?? []
		totalRating = try? container.decode(Int.self, forKey: .totalRating)
		totalRatingCount = (try? container.decode(Int.self, forKey: .totalRatingCount)) ?? 0
		aggregatedRating = try? container.decode(Int.self, forKey: .aggregatedRating)
		screenshots = (try? container.decode([Screenshot].self, forKey: .screenshots)) ?? []
		genres = (try? container.decode([Genre].self, forKey: .genres)) ?? []
		platforms =  (try? container.decode([Platform].self, forKey: .platforms)) ?? []
		cover = (try? container.decode(Cover.self, forKey: .cover)) ?? nil
	}
}

public extension Game {
	enum Category: Int, Codable {
		case main_game = 0
		case dlc_addon
		case expansion
		case bundle
	}
}
