import Foundation
import Core

public protocol CoreProviding: AnyProvider {
	var games: any AppGamesService { get }
	var image: any AppImageLoaderService { get }
}
