import Combine
import Core
import Foundation
import GBFoundation
import GamebaseUI
import UIKit

@MainActor
public class GamesListViewModel: ObservableObject {
	
	// MARK: - Dependencies
	
	private let service: GamesListService
	private let viewData: GamesListViewData
	private let formatter: ImageURLFormatting
	private let imageCache: AnyCacheOf<ImageCache>
	private var cancellables: [AnyCancellable] = []
	
	// MARK: - Input
	
	let didTapGame = PassthroughSubject<GamesListViewState.GameItem, Never>()
	let didTapSearch = PassthroughSubject<Void, Never>()
	let didActionImageLoading = PassthroughSubject<GamesListViewState.GameItem, Never>()
	let didActionLoadMore = PassthroughSubject<Void, Never>()
	let didBeginViewTransition = PassthroughSubject<ViewTransitionData, Never>()
	let willBeginViewTransition = PassthroughSubject<ViewTransitionData, Never>()
	
	public let didDismiss: PassthroughSubject<Void, Never> = .init()
	
	// MARK: - Output
	
	public private(set) lazy var onOpenGameDetail: AnyPublisher<GameDetailViewData, Never> = makeOpenGameDetail()
	public private(set) lazy var onOpenSearch: AnyPublisher<Void, Never> = makeOpenSearch()
	public private(set) lazy var onTransition: AnyPublisher<ViewTransitionData, Never> = makeTransition()
	
	// MARK: - Props
	
	@Published var state: GamesListViewState
	
	// MARK: - Init
	
	public init(
		service: GamesListService,
		viewData: GamesListViewData,
		formatter: ImageURLFormatting,
		imageCache: AnyCache<URL, UIImage>
	) {
		self.service = service
		self.viewData = viewData
		self.formatter = formatter
		self.imageCache = imageCache
		self.state = .initial
		self.setupBindings()
	}
	
	func refreshData() async {
		guard state.hasGames == false else {
			return
		}
		await fetchGames()
	}
	
	private func fetchGames() async  {
		state = state.gamesLoading()
		do {
			let model = try await service.games()
			state = state.gamesSuccess(with: model, cache: imageCache, formatter: formatter)
		} catch let serviceError as AppGamesServiceErrorResponse {
			state = state.gamesError(serviceError)
		} catch {
			state = state.updatingFetchState(to: .empty)
		}
	}
	
	private func setupBindings() {
		didActionLoadMore
			.asyncSink(weak: self) { this, _ in
				await this.fetchGames()
			}
			.store(in: &cancellables)
		
		didActionImageLoading
			.asyncSink(weak: self) { this, item in
				await this.fetchImage(for: item)
			}
			.store(in: &cancellables)
		
		let didTap = Publishers.Merge(didTapGame.mapToVoid(), didTapSearch)
			.map { true }
		
		let didDismiss = didDismiss
			.map { false }
		
		didTap.merge(with: didDismiss)
			.compactMap(weak: self) { this, shouldPresent in
				this.state.with { $0.isDetailPresented = shouldPresent }
			}
			.assign(to: &$state)
	}
	
	private func fetchImage(for game: GamesListViewState.GameItem) async {
		if let image = await service.loadImage(for: game.coverURL) {
			state = state.updateBySetting(image: image, for: game)
		}
	}
}

// MARK: - Factory

extension GamesListViewModel {
	func makeOpenGameDetail() -> AnyPublisher<GameDetailViewData, Never> {
		didTapGame
			.compactMap(weak: self) { this, item in
				.init(
					entity: .entityId(item.id),
					presentation: .custom
				)
			}
			.eraseToAnyPublisher()
	}
	
	func makeOpenSearch() -> AnyPublisher<Void, Never> {
		didTapSearch.eraseToAnyPublisher()
	}
	
	func makeTransition() -> AnyPublisher<ViewTransitionData, Never> {
		Publishers.Merge(willBeginViewTransition, didBeginViewTransition)
			.eraseToAnyPublisher()
	}
}
