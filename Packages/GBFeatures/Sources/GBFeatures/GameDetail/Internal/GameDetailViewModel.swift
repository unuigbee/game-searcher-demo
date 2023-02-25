import Combine
import Foundation
import Core
import GBFoundation
import GamebaseUI

@MainActor
public final class GameDetailViewModel: ObservableObject, CombineCancellableHolder {
	// MARK: - Dependencies
	
	private let viewData: GameDetailViewData
	private let service: GameDetailService
	private let cache: any GameDetailCaching
	
	// MARK: - Input
	
	let didTapDismiss = PassthroughSubject<Void, Never>()
	let didTapScreenshot = PassthroughSubject<Int, Never>()
	public let onLoad: PassthroughSubject<GameDetailViewData, Never> = .init()
	public let didReceiveTransition: PassthroughSubject<ViewTransitionData, Never> = .init()
	
	// MARK: - Output
	
	public private(set) lazy var onDismiss: AnyPublisher<Void, Never> = didTapDismiss.eraseToAnyPublisher()
	
	// MARK: - Props
	
	@Published var state: GameDetailViewState
	
	// MARK: - Init
	
	public init(
		service: GameDetailService,
		viewData: GameDetailViewData,
		cache: some GameDetailCaching
	) {
		self.service = service
		self.viewData = viewData
		self.cache = cache
		self.state = .intial(viewData: viewData, cache: cache)
		self.setupBindings()
	}
	
	private func setupBindings() {
		onLoad
			.compactMap(\.entity?.id)
			.asyncSink(weak: self) { this, id in
				this.state = this.state.updateItem(using: this.cache, with: id)
				await this.fetchGame(for: id)
			}
			.store(in: &cancellables)
		
		didTapScreenshot
			.compactMap(weak: self) { this, index in
				guard let screenshots = this.state.item?.screenshots else {
					return this.state
				}
				return this.state.with {
					$0.selectedScreenshots = .init(urls: screenshots, focusIndex: index)
				}
			}
			.assign(to: &$state)
		
		setupTransitionBindings()
	}
	
	private func setupTransitionBindings() {
		didReceiveTransition
			.compactMap(weak: self) { this, data in
				this.state.with {
					$0.transitionData = .init(data: data)
					$0.isTransitioning = !data.isTransitionComplete
				}
			}
			.assign(to: &$state)
	}
	
	// MARK: - Async/Await
	
	func refreshData() async {
		if let id = viewData.entity?.id, viewData.presentation == .default {
			await fetchGame(for: id)
		}
	}
	
	private func fetchGame(for id: Int) async {
		state = state.itemLoading()
		do {
			let model = try await service.fetchGame(for: id)
			state = state.itemSuccess(with: model)
		} catch let serviceError as AppGamesServiceErrorResponse {
			state = state.itemError(with: serviceError)
		} catch {
			state = state.updatingFetchState(to: .empty)
		}
	}
	
	// MARK: - Combine
	
	private func fetchGame() -> AnyPublisher<GameDetailViewState, Never> {
		guard let id = viewData.entity?.id else { return .empty() }
		
		return service.fetchGame(for: id)
			.compactMap(weak: self) { this, model in
				this.state.itemSuccess(with: model)
			}
			.catchJust(weak: self) { this, error in
				this.state.itemError(with: error)
			}
			.prepend(state.itemLoading())
			.eraseToAnyPublisher()
	}
}
