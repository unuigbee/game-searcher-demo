import Foundation
import UIKit
import SwiftUI
import Core
import GBFoundation
import GamebaseUI

typealias GameDetailRequestState = RequestState<AppGamesServiceError>

public struct GameDetailViewState: Hashable, Then {
	var item: GameItem?
	var fetchState: FetchState
	var transitionData: TransitionData
	var selectedScreenshots: SelectedScreenshots
	var isTransitioning: Bool
}

extension GameDetailViewState {
	var isLoading: Bool {
		fetchState.isLoading
	}
	
	var hasItem: Bool {
		item != nil
	}
	
	enum FetchState: Hashable {
		case empty
		case cached
		case game(GameDetailRequestState)
	}
}

extension GameDetailViewState.FetchState {
	var error: AppGamesServiceErrorResponse? {
		switch self {
		case let .game(requestState):
			return requestState.requestError
		case .empty, .cached:
			return nil
		}
	}

	var isLoading: Bool {
		switch self {
		case let .game(requestState):
			return requestState == .loading
		case .empty, .cached:
			return false
		}
	}
}

extension GameDetailViewState {
	struct GameItem: Hashable, Identifiable {
		let id: Int
		let title: String
		let description: String?
		let publisher: String?
		let coverURL: URL?
		let cover: UIImage?
		let screenshots: [URL]
	}
}

extension GameDetailViewState.GameItem {
	init?(_ game: AppModels.Game?, cover: UIImage?) {
		guard let game = game else { return nil }
		
		self.id = game.id
		self.title = game.title
		self.description = game.description
		self.publisher = Self.publisher(game.involvedCompanies)
		self.coverURL = game.cover
			.flatMap { ImageURLFormatter.formattedImageURL(url: $0.url, for: .screenShotMedium) }
		self.cover = cover
		self.screenshots = game.screenshots
			.compactMap { ImageURLFormatter.formattedImageURL(url: $0.url, for: .screenShotMedium) }
	}
	
	static func publisher(_ involvedCompanies: [AppModels.InvolvedCompany]) -> String {
		guard let involvedCompany = involvedCompanies.first(where: { $0.publisher == true }) else {
			return "Publisher unknown"
		}

		return involvedCompany.company.name.capitalizingFirstLetter()
	}
}

extension GameDetailViewState {
	struct TransitionData: Then, Hashable {
		let safeArea: EdgeInsets
		let sourceFrame: CGRect
		var animationProgress: Double
		
		init(
			animationProgress: Double,
			safeArea: EdgeInsets,
			sourceFrame: CGRect
		) {
			self.animationProgress = animationProgress
			self.safeArea = safeArea
			self.sourceFrame = sourceFrame
		}
	}
}

extension GameDetailViewState.TransitionData {
	init(data: ViewTransitionData) {
		self.animationProgress = data.animatableData
		self.sourceFrame = data.sourceViewFrame
		self.safeArea = data.safeArea
	}
}

extension GameDetailViewState.TransitionData {
	static let empty: Self = .init(
		animationProgress: .zero,
		safeArea: .zero,
		sourceFrame: .zero
	)
}

extension GameDetailViewState {
	struct SelectedScreenshots: Hashable {
		var urls: [URL]?
		var focusIndex: Int = 0
	}
}
