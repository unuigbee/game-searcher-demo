import Foundation
import GBFoundation
import API

public extension AppModels {
	struct GameFilter: Hashable, Then {
		public let id: Int
		public internal(set) var filter: Filter
		
		public init(id: Int, filter: Filter) {
			self.id = id
			self.filter = filter
		}
		
		public enum Filter: String, Hashable {
			case topRated = "Top Rated"
			case fighting = "Fighting"
			case shooter = "Shooter"
			case moba = "MOBA"
			case arcade = "Adventure"
			case indie = "Indie"
			case sport = "Sport"
			case platform = "Platform"
			
			public var name: String {
				return self.rawValue
			}
		}
	}
}

public extension GameFilter {
	init(_ filter: AppModels.GameFilter) {
		self.init(id: filter.id, filter: Filter.init(filter.filter))
	}
}

public extension GameFilter.Filter {
	init(_ filter: AppModels.GameFilter.Filter) {
		switch filter {
		case .arcade:
			self = .arcade
		case .fighting:
			self = .fighting
		case .indie:
			self = .indie
		case .moba:
			self = .moba
		case .platform:
			self = .platform
		case .sport:
			self = .sport
		case .topRated:
			self = .topRated
		case .shooter:
			self = .shooter
		}
	}
}
