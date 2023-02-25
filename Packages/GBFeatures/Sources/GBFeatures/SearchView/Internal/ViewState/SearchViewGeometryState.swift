import GamebaseUI
import SwiftUI

struct SearchViewGeometryState: Hashable {
	var cache: [ItemGeometryPreferencesKey.Data]
	var source: Source
	var shouldContractSearchBar: Bool
}

extension SearchViewGeometryState {
	struct Source: Identifiable, Hashable {
		var id: Int
		var bounds: CGRect
	}
	
	static let initial: Self = .init(
		cache: [],
		source: .init(id: -1, bounds: .zero),
		shouldContractSearchBar: false
	)
}
