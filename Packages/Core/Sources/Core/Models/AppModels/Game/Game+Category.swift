import Foundation

public extension AppModels.Game {
	enum Category: Int, Hashable {
		case main_game = 0
		case dlc_addon
		case expansion
		case bundle
		
		public var description: String {
			switch self {
			case .main_game:
				return "main game"
			case .dlc_addon:
				return "dlc"
			case .expansion:
				return "expansions"
			case .bundle:
				return "bundles"
			}
		}
	}
}
