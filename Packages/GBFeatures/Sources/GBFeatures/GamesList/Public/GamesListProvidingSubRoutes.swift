import Foundation

public final class GamesListProvidingSubRoutes {
	public let gameDetail: any GameDetailProviding
	public let search: any SearchProviding
	
	public init(
		gameDetail: some GameDetailProviding,
		search: some SearchProviding
	) {
		self.gameDetail = gameDetail
		self.search = search
	}
}
