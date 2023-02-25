public final class SearchProvidingSubRoutes {
	public let gameDetail: any GameDetailProviding
	
	public init(gameDetail: some GameDetailProviding) {
		self.gameDetail = gameDetail
	}
}
