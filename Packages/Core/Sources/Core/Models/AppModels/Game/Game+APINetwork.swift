import Foundation
import API

extension AppModels.Game {
	init(with game: Game) {
		self.id = game.id
		self.title = game.title
		self.description = game.description
		self.category = game.category.flatMap(AppModels.Game.Category.init)
		self.involvedCompanies = game.involvedCompanies.map(AppModels.InvolvedCompany.init)
		self.cover = game.cover.flatMap(AppModels.Game.Cover.init)
		self.screenshots = game.screenshots.map(AppModels.Game.Screenshot.init)
		self.platforms = game.platforms.map(AppModels.Platform.init)
		self.totalRating = game.totalRating
		self.totalRatingCount = game.totalRatingCount
		self.aggregatedRating = game.aggregatedRating
	}
}

extension AppModels.Game.Cover {
	init(with cover: Cover) {
		self.id = cover.id
		self.url = cover.url
	}
}

extension AppModels.Game.Screenshot {
	init(with screenshot: Screenshot) {
		self.id = screenshot.id
		self.url = screenshot.url
	}
}

extension AppModels.Game.Category {
	init(_ category: Game.Category) {
		switch category {
		case .main_game:
			self = .main_game
		case .bundle:
			self = .bundle
		case .dlc_addon:
			self = .dlc_addon
		case .expansion:
			self = .expansion
		}
	}
}
