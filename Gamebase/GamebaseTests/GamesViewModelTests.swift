//
//  GamesViewModelTests.swift
//  GamebaseTests
//
//  Created by Emmanuel Unuigbe on 02/05/2021.
//

import XCTest
import Combine

import Engine
import Mocks
import Data
import Utility
import Services
@testable import Gamebase

class GamesViewModelTests: XCTestCase {
	private var cancellable: AnyCancellable?
	
	var sut: GamesViewModel!
	var mockGamesService: MockGamesService!
	var mockGamesCache: AnyCache<String, [Game]>!
	var mockGenreKeywordsCache: AnyCache<String, [Genre]>!
	
	override func setUp() {
		super.setUp()
		
		mockGamesService = MockGamesService()
		mockGenreKeywordsCache = .mockAppData(defaultValue: [])
		mockGamesCache = .mockAppData(defaultValue: [])
		
		sut = GamesViewModel(
			interactor: Engine(gamesService: mockGamesService),
			scheduler: .immediate,
			gamesCache: mockGamesCache,
			keywordCache: mockGenreKeywordsCache
		)
	}
	
	override func tearDown() {
		mockGamesService = nil
		mockGenreKeywordsCache = nil
		mockGamesCache = nil
		cancellable = nil
		sut = nil
		
		Mocks.mockSingletonsStore.removeAll()
		
		super.tearDown()
	}
	
	func testViewModelReceivesAndCachesFirstTenRecommendedGames() {
		// given
		let games: [Game] = Array(repeating: Game(id: 1, title: "title", description: nil), count: 10)
		mockGamesService.mockGamesResult = .success(games)
		
		// when
		sut.fetchGames()
		
		// then
		XCTAssertEqual(sut.recommendedGames.count, 10)
		XCTAssertEqual(mockGamesCache[GamesViewModel.recommendedGamesCacheKey]?.count, GamesViewModel.cacheLimit)
	}
	
	func testViewModelReceivedMoreRecommendedFetchedGames() {
		// given
		let firstBatch = Array(repeating: Game(id: 1, title: "title", description: nil), count: 10)
		let secondBatch: [Game] = Array(repeating: Game(id: 2, title: "title", description: nil), count: 5)
		let expectedCount = firstBatch.count + secondBatch.count
		
		mockGamesService.mockGamesResult = .success(firstBatch)
		
		// when
		sut.fetchGames()
		mockGamesService.mockGamesResult = .success(secondBatch)
		sut.fetchGames()
		
		// then
		XCTAssertEqual(sut.recommendedGames.count, expectedCount)
	}
	
	func testViewModelReceivedNoRecommendedGamesWhenError() {
		// given
		mockGamesService.mockGamesResult = .failure(.noGamesAvailable)
		
		// when
		sut.fetchGames()
		
		// then
		XCTAssertTrue(sut.recommendedGames.isEmpty)
	}
	
	func testViewModelRetainsCachedRecommendedGames() {
		// given
		let cachedGamesCount = 20
		let games: [Game] = Array(repeating: Game(id: 1, title: "title", description: nil), count: cachedGamesCount)
		mockGamesService.mockGamesResult = .failure(.noGamesAvailable)
		mockGamesCache.insert(games, for: GamesViewModel.recommendedGamesCacheKey)
		
		let sut = buildSUT()
		
		// when
		sut.fetchGames()
		
		// then
		XCTAssertNotNil(mockGamesCache[GamesViewModel.recommendedGamesCacheKey])
		XCTAssertEqual(sut.recommendedGames.count, cachedGamesCount)
	}
	
	func testViewModelFilterRowItemsCount() {
		let expectedFilterCount = GameFilter.Filter.allCases.count
		let genresForFilter = GameFilter.Filter.allCases
			.filter { $0 != .topRated }
			.enumerated()
			.map { index, filter in
				Genre(id: index, name: filter.name)
			}
		
		mockGenreKeywordsCache.insert(genresForFilter, for: AppData.Keys.genreList)
		
		XCTAssertEqual(cachedGenreKeywords?.count, genresForFilter.count)
		XCTAssertEqual(sut.filterRowItems.count, expectedFilterCount)
		XCTAssertEqual(sut.filterRowItems.first?.id, -1)
		XCTAssertEqual(sut.filterRowItems.first?.filter, .topRated)
	}
	
	func testViewModelReceivesCachedOrFetchedGamesForEveryFilter() {
		// given
		let gamesCountForFilter = 20
		let games: [Game] = Array(repeating: Game(id: 1, title: "game title", description: nil), count: gamesCountForFilter)
		
		let genresForFilter = GameFilter.Filter.allCases
			.filter { $0 != .topRated }
			.enumerated()
			.map { index, filter in
				Genre(id: index, name: filter.name)
			}
		
		mockGenreKeywordsCache.insert(genresForFilter, for: AppData.Keys.genreList)
		mockGamesService.mockGamesResult = .success(games)
		
		let expectedGamesCountForEveryFilter = GameFilter.Filter.allCases.count * gamesCountForFilter
		let expectedCacheLimit = 10
		var gamesForEachFilter: [GameProtocol] = []
		
		// when
		let filterRowItemIndices = sut.filterRowItems.indices
		filterRowItemIndices.forEach { index in
			sut.fetchGames(for: index)
			XCTAssertEqual(sut.filteredGames.count, gamesCountForFilter)
			gamesForEachFilter.append(contentsOf: sut.filteredGames)
		}
		
		// then
		XCTAssertEqual(gamesForEachFilter.count, expectedGamesCountForEveryFilter)
		XCTAssertEqual(mockGamesCache[GameFilter.Filter.topRated.name]?.count, expectedCacheLimit)
	}
	
	func testViewModelRetainsCachedGamesForFilter() {
		// given
		let expectedCacheLimit = 20
		let games: [Game] = Array(repeating: Game(id: 1, title: "title", description: nil), count: expectedCacheLimit)
		
		mockGamesCache.insert(games, for: GameFilter.Filter.topRated.name)
		mockGamesService.mockGamesResult = .failure(.noGamesAvailable)
	
		// when
		if let topRatedFilterIndex = sut.filterRowItems.firstIndex(where: { $0.filter == .topRated }) {
			sut.fetchGames(for: topRatedFilterIndex)
		} else {
			XCTFail("Top Rated filter does not exist!")
		}
		
		// then
		XCTAssertEqual(sut.filteredGames.count, expectedCacheLimit)
	}
	
	func testViewModelReceivesFetchedGamesForFilter() {
		// given
		let games: [Game] = Array(repeating: Game(id: 1, title: "title", description: nil), count: 20)
		mockGamesService.mockGamesResult = .success(games)
		
		// when
		if let topRatedFilterIndex = sut.filterRowItems.firstIndex(where: { $0.filter == .topRated }) {
			sut.fetchGames(for: topRatedFilterIndex)
		} else {
			XCTFail("Top Rated filter does not exist!")
		}
		
		// then
		XCTAssertEqual(sut.filteredGames.count, games.count)
		XCTAssertEqual(mockGamesCache[GameFilter.Filter.topRated.name]?.count, GamesViewModel.cacheLimit)
	}
	
	func testViewModelHasLoadedAllData() {
		// given
		let games: [Game] = Array(repeating: Game(id: 1, title: "title", description: nil), count: 20)
		mockGamesService.mockGamesResult = .success(games)
		
		let expectedAllDataHasLoadedOutput = [false, true]
		var allDataHasLoadedOutput: [Bool] = []
		
		cancellable = sut.$allDataHasLoaded
			.sink { allDataHasLoadedOutput.append($0) }
		
		// when
		if let topRatedFilterIndex = sut.filterRowItems.firstIndex(where: { $0.filter == .topRated }) {
			sut.fetchGames(for: topRatedFilterIndex)
		} else {
			XCTFail("Top Rated filter does not exist!")
		}
		
		sut.fetchGames()
		
		// then
		XCTAssertEqual(allDataHasLoadedOutput, expectedAllDataHasLoadedOutput)
	}
	
	func testViewModelHasLoadedAllCachedData() {
		// given
		let games: [Game] = Array(repeating: Game(id: 1, title: "title", description: nil), count: 20)
		mockGamesService.mockGamesResult = .failure(.noGamesAvailable)
		mockGamesCache.insert(games, for: GameFilter.Filter.topRated.name)
		mockGamesCache.insert(games, for: GamesViewModel.recommendedGamesCacheKey)
		
		// We need to pre-fill the cache with games data before the view model initialises, so
		// that $allDataHasLoaded still publishes a value of true even if there is only cached data available
		// and no games are fetched from the games service
		let sut = buildSUT()
		
		let expectedAllDataHasLoadedOutput = [false, true]
		var allDataHasLoadedOutput: [Bool] = []

		cancellable = sut.$allDataHasLoaded
			.sink { allDataHasLoadedOutput.append($0) }
		
		// when
		if let topRatedFilterIndex = sut.filterRowItems.firstIndex(where: { $0.filter == .topRated }) {
			sut.fetchGames(for: topRatedFilterIndex)
		} else {
			XCTFail("Top Rated filter does not exist!")
		}
		sut.fetchGames()
		
		// then
		XCTAssertNotNil(mockGamesCache[GameFilter.Filter.topRated.name])
		XCTAssertNotNil(mockGamesCache[GamesViewModel.recommendedGamesCacheKey])
		XCTAssertEqual(allDataHasLoadedOutput, expectedAllDataHasLoadedOutput)
	}
	
	func testViewModelResetsIsFetchingFlagWhenDataIsFetched() {
		// given
		let games: [Game] = Array(repeating: Game(id: 1, title: "title", description: nil), count: 20)
		mockGamesService.mockGamesResult = .success(games)
		
		let expectedIsFetchingOutput = [false, true, false]
		var isFetchingOutput: [Bool] = []
		
		cancellable = sut.$isFetching
			.sink { isFetchingOutput.append($0) }
	
		// when
		sut.fetchGames()
		
		// then
		XCTAssertEqual(isFetchingOutput, expectedIsFetchingOutput)
	}
	
	private var cachedGenreKeywords: [Genre]? {
		mockGenreKeywordsCache[AppData.Keys.genreList]
	}
	
	private func buildSUT() -> GamesViewModel {
		return GamesViewModel(
			interactor: Engine(gamesService: mockGamesService),
			scheduler: .immediate,
			gamesCache: mockGamesCache,
			keywordCache: mockGenreKeywordsCache
		)
	}
}
