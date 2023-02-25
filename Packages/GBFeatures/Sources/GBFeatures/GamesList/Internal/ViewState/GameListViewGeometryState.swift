import SwiftUI
import Components
import GamebaseUI

struct GameListViewGeometryState: Hashable {
	var cache: Cache
	var source: Source
}

extension GameListViewGeometryState {
	struct Source: Identifiable, Hashable {
		var id: Int
		var bounds: CGRect
		var namespace: ActiveNameSpace
	}
	
	struct Cache: Hashable {
		var games: [ItemGeometryPreferencesKey.Data]
		var search: CGRect
	}
	
	enum ActiveNameSpace: Hashable {
		case empty
		case game
		case search
	}
	
	static let initial: Self = .init(
		cache: .init(games: [], search: .zero),
		source: .init(id: -1, bounds: .zero, namespace: .empty)
	)
}
