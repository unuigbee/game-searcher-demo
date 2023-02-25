//
//  SearchViewModelTests.swift
//  GamebaseTests
//
//  Created by Emmanuel Unuigbe on 08/06/2021.
//

import XCTest
import Foundation
import Combine

import Engine
import Mocks
import Data
import Utility
@testable import Gamebase

class SearchViewModelTests: XCTestCase {
	var sut: SearchViewModel!
	var mockGamesService: MockGamesService!
	var mockCache: AnyCache<String, [SearchKeyword]>!
	private var cancellable: AnyCancellable?
	
	override func setUp() {
		super.setUp()
		
		mockGamesService = MockGamesService()
		mockCache = .mockAppData(defaultValue: [])
		
		sut = SearchViewModel(
			interactor: Engine(gamesService: mockGamesService),
			cache: mockCache
		)
	}
	
	override func tearDown() {
		mockGamesService = nil
		mockCache = nil
		sut = nil
		
		Mocks.mockSingletonsStore = [:]
		
		super.tearDown()
	}
	
	func testPositiveSearchRequestReceivesGames() {
		let zeldaGames: [Game] = [
			.init(id: 1, title: "The Legend of Zelda: Breath of the wild", description: nil),
			.init(id: 2, title: "The Legend of Zelda: Ocarina of Time", description: nil),
			.init(id: 3, title: "The Legend of Zelda: Majora's Mask", description: nil)
		]
		
		mockGamesService.mockGamesResult = .success(zeldaGames)
		sut.search("Zelda")
		
		_ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 1.5)
		XCTAssertEqual(sut.games.count, 3)
	}
	
	func testEmptySearchRequestClearsGames() {
		let zeldaGames: [Game] = [
			.init(id: 1, title: "The Legend of Zelda: Breath of the wild", description: nil),
			.init(id: 2, title: "The Legend of Zelda: Ocarina of Time", description: nil),
			.init(id: 3, title: "The Legend of Zelda: Majora's Mask", description: nil)
		]
		
		mockGamesService.mockGamesResult = .success(zeldaGames)
		sut.search("Zelda")

		_ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 1.5)
		XCTAssertEqual(sut.games.count, 3)
		
		sut.search("")
		
		XCTAssertEqual(sut.games.count, 0)
	}
	
	func testNegativeSearchClearsRecentSearchedGames() {
		let initialSearchResults: [Game] = [
			.init(id: 1, title: "The Legend of Zelda: Breath of the wild", description: nil),
			.init(id: 2, title: "The Legend of Zelda: Ocarina of Time", description: nil),
			.init(id: 3, title: "The Legend of Zelda: Majora's Mask", description: nil)
		]
		
		mockGamesService.mockGamesResult = .success(initialSearchResults)
		sut.search("Zelda")
		
		_ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 1.5)
		XCTAssertEqual(sut.games.count, 3)
		
		mockGamesService.mockGamesResult = .failure(.noGamesAvailable)
		sut.search("Failed/Negative Search")
		
		_ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 1.5)
		XCTAssertEqual(sut.games.count, 0)
	}
	
	func testSearchPagination() {
		let initialSearch: [Game] = [
			.init(id: 1, title: "The Legend of Zelda: Breath of the wild", description: nil),
			.init(id: 2, title: "The Legend of Zelda: Ocarina of Time", description: nil),
			.init(id: 3, title: "The Legend of Zelda: Majora's Mask", description: nil)
		]
		
		let subsequentFetch: [Game] = [
			.init(id: 4, title: "The Legend of Zelda: Link's Awakening", description: nil),
			.init(id: 5, title: "The Legend of Zelda: Twilight Princess", description: nil),
			.init(id: 6, title: "The Legend of Zelda: Wind Waker", description: nil)
		]
		
		mockGamesService.mockGamesResult = .success(initialSearch)
		sut.search("Zelda")
		
		_ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 1.5)
		XCTAssertEqual(sut.games.count, 3)
		
		mockGamesService.mockGamesResult = .success(subsequentFetch)
		sut.fetchMore(of: "Zelda")
		
		_ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 1.5)
		XCTAssertEqual(sut.games.count, 6)
	}
	
	func testPositiveSearchGeneratesCachedKeyword() {
		let search: [Game] = [
			.init(id: 1, title: "The Legend of Zelda: Breath of the wild", description: nil),
			.init(id: 2, title: "The Legend of Zelda: Ocarina of Time", description: nil),
			.init(id: 3, title: "The Legend of Zelda: Majora's Mask", description: nil)
		]
		
		mockGamesService.mockGamesResult = .success(search)
		sut.search("Zelda")
		
		_ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 1.5)
		
		XCTAssertEqual(sut.recentSearches.first?.name, "zelda")
		XCTAssertEqual(cachedSearchKeywords?.first?.name, "zelda")
	}
	
	func testNegativeSearchGeneratesNoKeyword() {
		let negativeSearchResults: [Game] = []
		
		mockGamesService.mockGamesResult = .success(negativeSearchResults)
		sut.search("Negative Search")
		
		_ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 1.5)
		XCTAssertEqual(sut.recentSearches.count, 0)
		XCTAssertEqual(cachedSearchKeywords?.count, 0)
	}
	
	func testViewModelDeletesCachedKeyword() {
		let search: [Game] = [
			.init(id: 1, title: "The Legend of Zelda: Breath of the wild", description: nil),
			.init(id: 2, title: "The Legend of Zelda: Ocarina of Time", description: nil),
			.init(id: 3, title: "The Legend of Zelda: Majora's Mask", description: nil)
		]
		
		mockGamesService.mockGamesResult = .success(search)
		sut.search("Zelda")
		
		_ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 1.5)
		XCTAssertEqual(sut.recentSearches.first?.name, "zelda")
		XCTAssertEqual(cachedSearchKeywords?.first?.name, "zelda")
		
		sut.deleteKeyword("zelda")
		XCTAssertEqual(sut.recentSearches.count, 0)
		XCTAssertEqual(cachedSearchKeywords?.count, 0)
	}
	
	func testCachedSearchedKeywordsIsLimitedToThree() {
		let search: [Game] = [
			.init(id: 1, title: "Pokemon", description: nil),
		]
		
		let keywordOne = SearchKeyword(name: "zelda")
		let keywordTwo = SearchKeyword(name: "horizon")
		mockCache.insert([keywordOne, keywordTwo], for: SearchViewModel.searchedKeywordsCacheKey)
		
		let keywordThree = SearchKeyword(name: "god of war")
		mockCache.insert([keywordOne, keywordTwo, keywordThree], for: SearchViewModel.searchedKeywordsCacheKey)
		
		mockGamesService.mockGamesResult = .success(search)
		sut.search("Pokemon")
		
		_ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 1.5)
		
		XCTAssertEqual(sut.recentSearches.count, 3)
		XCTAssertEqual(cachedSearchKeywords?.count, 3)
		XCTAssertEqual(sut.recentSearches.first?.name, "pokemon")
		XCTAssertEqual(cachedSearchKeywords?.first?.name, "pokemon")
		XCTAssertNotEqual(sut.recentSearches.last, keywordThree)
		XCTAssertNotEqual(cachedSearchKeywords?.last, keywordThree)
	}
	
	func testIsSearchingFlagResetsWhenSearchRequestReceivesGames() {
		// given
		let searchResults: [Game] = [
			.init(id: 1, title: "The Legend of Zelda: Breath of the wild", description: nil)
		]
		mockGamesService.mockGamesResult = .success(searchResults)
		
		let expectedIsSearchingOutput = [false, true, false]
		var isSearchingOutput: [Bool] = []
		
		cancellable = sut.$isSearching
			.sink { isSearchingOutput.append($0) }
		// when
		sut.search("Zelda")
		
		// then
		_ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 1.5)
		XCTAssertEqual(isSearchingOutput, expectedIsSearchingOutput)
	}
	
	func testIsFetchingFlagResetsWhenSearchRequestFetchesMoreGames() {
		// given
		let initialSearch: [Game] = [
			.init(id: 1, title: "The Legend of Zelda: Breath of the wild", description: nil)
		]
		
		let subsequentFetch: [Game] = [
			.init(id: 2, title: "The Legend of Zelda: Link's Awakening", description: nil),
		]
		
		mockGamesService.mockGamesResult = .success(initialSearch)
		sut.search("Zelda")
		_ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 1.5)
		
		let expectedIsFetchingOutput = [false, true, false]
		var isFetchingOutput: [Bool] = []
		cancellable = sut.$isFetching
			.sink { isFetchingOutput.append($0) }
		
		// when
		mockGamesService.mockGamesResult = .success(subsequentFetch)
		sut.fetchMore(of: "Zelda")
		
		// then
		_ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 1.5)
		XCTAssertEqual(isFetchingOutput, expectedIsFetchingOutput)
	}
	
	private var cachedSearchKeywords: [SearchKeyword]? {
		mockCache[SearchViewModel.searchedKeywordsCacheKey]
	}
}

struct MockSearchFormatter: TextFormatter {
	func format(_ text: String) -> String {
		return text
	}
}
