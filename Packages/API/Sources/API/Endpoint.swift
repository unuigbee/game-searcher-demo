import Foundation

extension API {
	public struct Endpoints {
		private let baseURL: String
		
		var games: String { urlPath(for: .games) }
		var screenshots: String { urlPath(for: .screenshots) }
		var covers: String { urlPath(for: .covers) }
		var involvedCompanies: String { urlPath(for: .involvedCompanies) }
		var companies: String { urlPath(for: .companies) }
		var genres: String { urlPath(for: .genres) }
		var platform: String { urlPath(for: .platform) }
		var platformLogos: String { urlPath(for: .platformLogos) }
		
		public init(baseURL: String) {
			self.baseURL = baseURL
		}
		
		private func urlPath(for resource: Resource) -> String {
			switch resource {
			case .games:
				return baseURL + "games"
			case .screenshots:
				return baseURL + "screenshots"
			case .covers:
				return baseURL + "covers"
			case .involvedCompanies:
				return baseURL + "involved_companies"
			case .companies:
				return baseURL + "companies"
			case .genres:
				return baseURL + "genres"
			case .platform:
				return baseURL + "platforms"
			case .platformLogos:
				return baseURL + "platform_logos"
			}
		}
		
		public enum Resource: String {
			case games
			case covers
			case screenshots
			case involvedCompanies
			case companies
			case genres
			case platform
			case platformLogos
		}
	}
}
