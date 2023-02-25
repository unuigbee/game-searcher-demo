import Foundation

public extension AppModels.Game {
	struct Rating: Hashable {
		var totalRating: Int?
		var totalRatingCount: Int
		var aggregatedRating: Int?
	}
	
	var rating: Rating {
		.init(
			totalRating: totalRating,
			totalRatingCount: totalRatingCount,
			aggregatedRating: aggregatedRating
		)
	}
}
