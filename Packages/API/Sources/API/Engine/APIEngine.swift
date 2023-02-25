import Foundation
import Combine

public class APIEngine {
	private let taskManager: APITaskManager
	
	public let genre: GenreService
	public let games: GamesService
	public let screenshot: ScreenshotService
	public let cover: CoverService
	public let platform: PlatformService
	
	public init(
		clientId: String,
		clientSecret: String,
		clientGrantType: String,
		oAuthRoot: String,
		apiRoot: String
	) {
		let authConfig = AuthConfig(
			clientId: clientId,
			clientSecret: clientSecret,
			grantType: clientGrantType,
			oAuthRoot: oAuthRoot
		)
		let authSession = SecurePersistedAuthTokenSession(accountID: authConfig.clientId)
		let authenticator = APIAuthenticationTask(authSession: authSession, config: authConfig)
		let taskManager = APITaskManager(
			clientId: authConfig.clientId,
			requester: URLSession.shared,
			authenticator: authenticator
		)
		let endpoints = API.Endpoints(baseURL: apiRoot)
		
		self.taskManager = taskManager
		self.games = GamesAPI(apiTaskManager: taskManager, endpoints: endpoints)
		self.genre = GenreAPI(endpoints: endpoints)
		self.screenshot = ScreenshotAPI(endpoints: endpoints)
		self.cover = CoverAPI(endpoints: endpoints)
		self.platform = PlatformAPI(endpoints: endpoints)
	}
}

public protocol HasGenreService {
	var genre: GenreService { get }
}

public protocol HasGamesService {
	var games: GamesService { get }
}

public protocol HasScreenshotService {
	var screenshot: ScreenshotService { get }
}

public protocol HasPlatfromService {
	var platform: PlatformService { get }
}

public protocol HasCoverService {
	var cover: CoverService { get }
}

extension APIEngine: HasGamesService {}
extension APIEngine: HasGenreService {}
extension APIEngine: HasScreenshotService {}
extension APIEngine: HasCoverService {}
extension APIEngine: HasPlatfromService {}
