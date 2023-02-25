import Foundation
import API

extension AppModels.Platform {
	init(_ platform: Platform) {
		self.id = platform.id
		self.name = platform.name
		self.category = platform.category.flatMap(AppModels.Platform.Category.init)
		self.logo = platform.logo.flatMap(AppModels.Platform.Logo.init)
		self.abbreviation = platform.abbreviation
		self.alternativeName = platform.alternativeName
		self.generation = platform.generation
		self.logoId = platform.logoId
	}
}

extension AppModels.Platform.Category {
	init(_ category: Platform.Category) {
		switch category {
		case .platform:
			self = .platform
		case .arcade:
			self = .arcade
		case .computer:
			self = .computer
		case .console:
			self = .console
		case .operating_system:
			self = .operating_system
		case .portable_console:
			self = .portable_console
		}
	}
}

extension AppModels.Platform.Logo {
	init(_ logo: Platform.Logo) {
		self.id = logo.id
		self.game = logo.game
		self.imageId = logo.imageId
		self.url = logo.url
	}
}

