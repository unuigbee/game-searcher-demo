import GamebaseFacade
import GBFeatures

final class FeaturesProvider: FeaturesProviding {
	// MARK: - Dependencies
	
	unowned let provider: any Providing
	
	private(set) lazy var gamesList: any GamesListProviding = makeGamesListProvider()
	private(set) lazy var gameDetail: any GameDetailProviding = makeGameDetailProvider()
	private(set) lazy var search: any SearchProviding = makeSearchProvider()
	
	init(provider: Providing) {
		self.provider = provider
	}
	
	// MARK: - Factory
	
	private func makeGamesListProvider() -> any GamesListProviding {
		GamesListProvider(provider: provider)
	}
	
	private func makeGameDetailProvider() -> any GameDetailProviding {
		GameDetailProvider(provider: provider)
	}
	
	private func makeSearchProvider() -> any SearchProviding {
		SearchProvider(provider: provider)
	}
}
