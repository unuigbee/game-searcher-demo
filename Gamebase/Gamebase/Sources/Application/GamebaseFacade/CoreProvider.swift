import GamebaseFacade
import Core
import API

final class CoreProvider: CoreProviding {
	// MARK: - Dependencies
	unowned let provider: any Providing
	private lazy var api: APIEngine = makeAPIEngine()
	
	// MARK: Props
	lazy var games: any AppGamesService = makeAppGamesService()
	lazy var image: any AppImageLoaderService = makeAppImageLoaderService()
	
	init(provider: Providing) {
		self.provider = provider
	}
	
	private func makeAPIEngine() -> APIEngine {
		let config = provider.config.appConfig.vendors.gamebaseAPIVendorConfig
		
		return APIEngine(
			clientId: config.clientId,
			clientSecret: config.clientSecret,
			clientGrantType: config.grantType,
			oAuthRoot: config.oAuthRoot,
			apiRoot: config.apiRoot
		)
	}
	
	private func makeAppGamesService() -> any AppGamesService {
		DefaultAppGamesService(remoteService: api.games)
	}
	
	private func makeAppImageLoaderService() -> any AppImageLoaderService {
		DefaultAppImageLoaderService(cache: .shared)
	}
}
