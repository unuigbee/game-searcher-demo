import GBFeatures

@MainActor public protocol FeaturesProviding: AnyProvider {
	var gamesList: any GamesListProviding { get }
	var gameDetail: any GameDetailProviding { get }
	var search: any SearchProviding { get }
}
