import SwiftUI
import GamebaseUI

struct GameDetailViewGeometryState: Hashable {
	var cache: [ItemGeometryPreferencesKey.Data]
	var source: Source
	var titleRect: CGRect
	var headerVisibility: CGFloat
	var scrollOffset: CGFloat
	var collaspsibleHeaderHeight: CGFloat
}

extension GameDetailViewGeometryState {
	struct Source: Identifiable, Hashable {
		var id: Int
		var bounds: CGRect
	}
	
	static let initial: Self = .init(
		cache: [],
		source: .init(id: -1, bounds: .zero),
		titleRect: .zero,
		headerVisibility: 1,
		scrollOffset: .zero,
		collaspsibleHeaderHeight: .zero
	)
}
