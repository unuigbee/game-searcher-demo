import Core
import GBFoundation
import Combine
import UIKit

@MainActor
public final class GameDetailService {
	private let gamesService: any AppGamesService
	private let imageLoaderService: any AppImageLoaderService
	private let cache: AnyCacheOf<GameCache>
	private(set) var model: GameDetailServiceModel = .empty()
	
	public init(
		gamesService: some AppGamesService,
		imageLoaderService: some AppImageLoaderService,
		cache: AnyCacheOf<GameCache>
	) {
		self.gamesService = gamesService
		self.imageLoaderService = imageLoaderService
		self.cache = cache
	}
	
	// MARK: - Async/Await
	
	func fetchGame(for id: Int) async throws -> GameDetailServiceModel {
		let game = try await gamesService.game(for: id)
		let cover = await getCover(for: game.cover?.url)
		model = model.settingGame(with: game, cover: cover)
		return model
	}
	
	private func getCover(for url: String?) async -> UIImage? {
		guard
			let url,
			let formattedURL = ImageURLFormatter.formattedImageURL(url: url, for: .screenShotMedium)
		else { return nil }
		
		let image = await imageLoaderService.image(for: formattedURL)
		
		return image
	}
	
	// MARK: - Combine
	
	func fetchGame(for id: Int) -> AnyPublisher<GameDetailServiceModel, AppGamesServiceErrorResponse> {
		getGame(for: id)
			.map(model.updatingGame(with:))
			.flatMap(weak: self) { this, model in
				this.getImage(for: model.game?.cover?.url)
					.map(model.updatingCover(with:))
					.setFailureType(to: AppGamesServiceErrorResponse.self)
			}
			.handleEvents(receiveOutput: { [weak self] in self?.model = $0 })
			.eraseToAnyPublisher()
	}
	
	private func getGame(for id: Int) -> AnyPublisher<AppModels.Game, AppGamesServiceErrorResponse> {
		gamesService.game(for: id)
			.prepend(
				cache.publisher
					.item(for: id)
					.setFailureType(to: AppGamesServiceErrorResponse.self)
			)
			.eraseToAnyPublisher()
	}
	
	private func getImage(for url: String?) -> AnyPublisher<UIImage?, Never> {
		guard
			let url = url,
			let formattedURL = ImageURLFormatter.formattedImageURL(url: url, for: .screenShotMedium)
		else { return .just(nil) }
		
		return imageLoaderService.image(for: formattedURL)
	}
}

// MARK: Service Model

public struct GameDetailServiceModel {
	var game: AppModels.Game?
	var cover: UIImage?
}

private extension GameDetailServiceModel {
	static func empty() -> Self {
		.init(game: nil, cover: nil)
	}
	
	func updatingGame(with game: AppModels.Game) -> Self {
		.init(
			game: game,
			cover: cover
		)
	}
	
	func updatingCover(with cover: UIImage?) -> Self {
		.init(
			game: game,
			cover: cover
		)
	}
	
	func settingGame(with game: AppModels.Game, cover: UIImage?) -> Self {
		.init(
			game: game,
			cover: cover
		)
	}
}
