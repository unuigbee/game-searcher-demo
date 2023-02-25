//
//  GameDetailViewModelTests.swift
//  GamebaseTests
//
//  Created by Emmanuel Unuigbe on 10/07/2021.
//

import XCTest
import Foundation
import Combine

import Engine
import Mocks
import Data
import Utility
@testable import Gamebase

class GameDetailViewModelTests: XCTestCase {
	var sut: GameDetailViewModel!
	var mockGamesService: MockGamesService!
	var mockGameCache: AnyCache<Int, Game>!
	
	private var cancellable: AnyCancellable?
	
	override func setUp() {
		mockGameCache = .mock
		mockGamesService = MockGamesService()
		
		super.setUp()
	}
	
	override func tearDown() {
		mockGamesService = nil
		mockGameCache = nil
		cancellable = nil
		sut = nil
		
		super.tearDown()
	}
	
	func testViewModelUpdatesAndCachesFetchedGame() {
		// given
		let sut = buildSUT(with: .init(id: 1, title: "Doom: Eternal", description: nil))
		
		let expected = (id: 1, title: "Doom: Eternal", description: "fetched description")
		let fetchedGame = Game(id: expected.id, title: expected.title, description: expected.description)
		mockGamesService.mockGameResult = .success(fetchedGame)
		
		// when
		sut.fetchGame()
		
		// then
		XCTAssertEqual(sut.game.id, expected.id)
		XCTAssertEqual(sut.game.title, expected.title)
		XCTAssertEqual(sut.game.description, expected.description)
		XCTAssertEqual(mockGameCache[expected.id]?.id, expected.id)
		XCTAssertEqual(mockGameCache[expected.id]?.title, expected.title)
		XCTAssertEqual(mockGameCache[expected.id]?.description, expected.description)
	}
	
	func testExpectedGamePublisherOutput() {
		// given
		let initialGame = Game(id: 1, title: "Doom: Eternal", description: nil)
		let sut = buildSUT(with: initialGame)
		
		let expectedFetchedGame = (id: 1, title: "Doom: Eternal", description: "fetched description")
		let expectedCachedGame = (id: 1, title: "Doom: Eternal", description: "cached description")
		
		let cachedGame: Game = .init(id: 1, title: "Doom: Eternal", description: "cached description")
		mockGameCache.insert(cachedGame, for: expectedCachedGame.id)
		
		let fetchedGame = Game(id: expectedFetchedGame.id, title: expectedFetchedGame.title, description: expectedFetchedGame.description)
		mockGamesService.mockGameResult = .success(fetchedGame)
		
		let expectedGameOutput: [GameProtocol] = [initialGame, cachedGame, fetchedGame]
		var gameOutput: [GameProtocol] = []
		
		cancellable = sut.$game
			.sink(receiveValue: { gameOutput.append($0) })
		
		// when
		sut.fetchGame()
		
		// then
		XCTAssertEqual(gameOutput.count, expectedGameOutput.count)
		XCTAssertEqual(gameOutput.first?.description, nil)
		XCTAssertEqual(gameOutput[1].description, expectedGameOutput[1].description)
		XCTAssertEqual(gameOutput.last?.description, expectedGameOutput.last?.description)
		XCTAssertEqual(mockGameCache[expectedFetchedGame.id]?.description, expectedFetchedGame.description)
	}
	
	func testIsLoadingPublisherOutputWhenGameIsFetched() {
		// given
		let sut = buildSUT(with: Game(id: 1, title: "Doom: Eternal", description: nil))
		
		let expectedFetchedGame = (id: 1, title: "Doom: Eternal", description: "fetched description")
		
		let fetchedGame = Game(id: expectedFetchedGame.id, title: expectedFetchedGame.title, description: expectedFetchedGame.description)
		mockGamesService.mockGameResult = .success(fetchedGame)
		
		let expectedIsLoadingOutput: [Bool] = [false, true, false]
		var isLoadingOutput: [Bool] = []
		
		cancellable = sut.$isLoading
			.sink(receiveValue: { isLoadingOutput.append($0) })
		
		// when
		sut.fetchGame()
		
		// then
		XCTAssertEqual(isLoadingOutput.count, expectedIsLoadingOutput.count)
		XCTAssertEqual(isLoadingOutput, expectedIsLoadingOutput)
	}
		
	func testIsLoadingPublisherOutputWhenNoGameIsFetched() {
		// given
		let sut = buildSUT(with: Game(id: 1, title: "Doom: Eternal", description: nil))
		mockGamesService.mockGameResult = .failure(.noGameAvailable)
		
		let expectedIsLoadingOutput: [Bool] = [false, true]
		var isLoadingOutput: [Bool] = []
		
		cancellable = sut.$isLoading
			.sink(receiveValue: { isLoadingOutput.append($0) })
		
		// when
		sut.fetchGame()
		
		// then
		XCTAssertEqual(isLoadingOutput.count, expectedIsLoadingOutput.count)
		XCTAssertEqual(isLoadingOutput, expectedIsLoadingOutput)
	}
	
	func testIsLoadingPublisherOutputWhenOnlyCachedGameIsAvailable() {
		// given
		let sut = buildSUT(with: Game(id: 1, title: "Doom: Eternal", description: nil))
		mockGamesService.mockGameResult = .failure(.noGameAvailable)
		
		let cachedGame: Game = .init(id: 1, title: "Doom: Eternal", description: "cached description")
		mockGameCache.insert(cachedGame, for: cachedGame.id)
		
		let expectedIsLoadingOutput: [Bool] = [false, true, false]
		var isLoadingOutput: [Bool] = []
		
		cancellable = sut.$isLoading
			.sink(receiveValue: { isLoadingOutput.append($0) })
		
		// when
		sut.fetchGame()
		
		// then
		XCTAssertEqual(isLoadingOutput.count, expectedIsLoadingOutput.count)
		XCTAssertEqual(isLoadingOutput, expectedIsLoadingOutput)
	}
	
	private func buildSUT(with initialGame: Game) -> GameDetailViewModel {
		sut = GameDetailViewModel(
			game: initialGame,
			interactor: Engine(gamesService: mockGamesService),
			scheduler: .immediate,
			gameCache: mockGameCache
		)
		
		return sut
	}
}
