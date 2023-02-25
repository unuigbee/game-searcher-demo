import Foundation
import Core

public typealias GameDetailViewEntity = ViewEntity<AppModels.Game>

public struct GameDetailViewData {
	public let entity: GameDetailViewEntity?
	public let presentation: Presentation
	
	public init(entity: GameDetailViewEntity?, presentation: Presentation) {
		self.entity = entity
		self.presentation = presentation
	}
}

extension GameDetailViewData {
	public enum Presentation {
		case `default`
		case custom
	}
}
