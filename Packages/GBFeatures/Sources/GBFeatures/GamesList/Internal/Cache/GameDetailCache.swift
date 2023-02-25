import Foundation
import UIKit
import GBFoundation
import Core

public protocol GameDetailCaching {
	func image(for url: URL) -> UIImage?
	func game(for id: Int) -> AppModels.Game?
}

public struct GameDetailCache: GameDetailCaching {
	private let imageCache: AnyCache<URL, UIImage>
	private let gameCache: AnyCache<Int, AppModels.Game>
	
	public init(
		image: AnyCache<URL, UIImage>,
		game: AnyCache<Int, AppModels.Game>
	) {
		self.imageCache = image
		self.gameCache = game
	}
	
	public func image(for url: URL) -> UIImage? {
		imageCache.item(for: url)
	}
	
	public func game(for id: Int) -> AppModels.Game? {
		gameCache.item(for: id)
	}
}
