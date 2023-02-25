import Foundation
import API

public struct DefaultGamesModel: Hashable {
	public internal(set) var games: [AppModels.Game]
	public internal(set) var nextCursor: Cursor
}

extension DefaultGamesModel {
	init(_ games: [Game], nextCursor: Cursor) {
		self = .init(
			games: games.map(AppModels.Game.init),
			nextCursor: nextCursor
		)
	}
}
