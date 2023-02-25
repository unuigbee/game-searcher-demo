import Foundation
import Combine
import UIKit
import Core
import GBFoundation
import GamebaseUI

@MainActor
public final class SearchViewModel: ObservableObject, CombineCancellableHolder {
	// MARK: - Dependencies
	
	private let viewData: SearchViewData
	private let service: SearchViewService
	private let cache: AnyCache<URL, UIImage>
	private let userPreferences: any SearchUserPreferencesStoring
	
	// MARK: - Input
	
	let didClearSearch = PassthroughSubject<Void, Never>()
	let didTapDismiss = PassthroughSubject<Void, Never>()
	let didTapSearchTag = PassthroughSubject<UUID, Never>()
	let didClearSearchTag = PassthroughSubject<UUID, Never>()
	let didActionImageLoading = PassthroughSubject<SearchViewState.GameItem, Never>()
	let didTapGame = PassthroughSubject<SearchViewState.GameItem, Never>()
	let didActionLoadMore = PassthroughSubject<Void, Never>()
	let didBeginViewTransition = PassthroughSubject<ViewTransitionData, Never>()
	let willBeginViewTransition = PassthroughSubject<ViewTransitionData, Never>()

	public let didReceiveTransition: PassthroughSubject<ViewTransitionData, Never> = .init()
	
	// MARK: - Output
	
	public private(set) lazy var onDismiss: AnyPublisher<Void, Never> = didTapDismiss.eraseToAnyPublisher()
	public private(set) lazy var onTransition: AnyPublisher<ViewTransitionData, Never> = makeTransition()
	
	public private(set) lazy var onOpenGameDetail: AnyPublisher<GameDetailViewData, Never> = makeOpenGameDetail()
	public let handleGameDetailResult: PassthroughSubject<Void, Never> = .init()
	
	// MARK: - Props
	
	@Published var state: SearchViewState
	
	// MARK: - Init
	
	public init(
		viewData: SearchViewData,
		service: SearchViewService,
		cache: AnyCache<URL, UIImage>,
		userPreferences: any SearchUserPreferencesStoring
	) {
		self.viewData = viewData
		self.service = service
		self.cache = cache
		self.userPreferences = userPreferences
		self.state = .initial
		self.setupBindings()
	}
	
	// MARK: - Bindings
	
	private func setupBindings() {
		setupSearchBindings()
		setupSearchTagBindings()
		setupTransitionBindings()
		
		didActionImageLoading
			.asyncSink(weak: self) { this, item in
				await this.fetchImage(for: item)
			}
			.store(in: &cancellables)
		
		didTapDismiss
			.compactMap(weak: self) { this, _ in
				this.state.clearingSearchResults()
			}
			.assign(to: &$state)
	}
	
	private func setupSearchBindings() {
		$state
			.map(\.searchTerm)
			.removeDuplicates()
			.debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
			.asyncSink(weak: self) { this, searchTerm in
				guard searchTerm.count > 3 else {
					this.state = this.state.resettingSearchResults()
					return
				}
				await this.getSearchResults(by: searchTerm, isLoadingMore: false)
			}
			.store(in: &cancellables)
		
		didClearSearch
			.compactMap(weak: self) { this, _ in
				this.state.clearingSearchResults()
			}
			.assign(to: &$state)
		
		didActionLoadMore
			.asyncSink(weak: self) { this, _ in
				await this.getSearchResults(
					by: this.state.searchTerm,
					isLoadingMore: true
				)
			}
			.store(in: &cancellables)
	}
	
	private func setupSearchTagBindings() {
		$state
			.map(\.searchTags)
			.removeDuplicates()
			.asyncSink(weak: self) { this, tags in
				guard tags.isEmpty == false else {
					return
				}
				let keywords = tags.map(\.keyword)
				await this.userPreferences.setSearchKeyWords(keywords)
			}
			.store(in: &cancellables)
		
		didTapSearchTag
			.compactMap(weak: self) { this, tagId in
				this.state.recentSearches.first(where: { $0.id == tagId })?.keyword
			}
			.compactMap(weak: self) { this, keyword in
				this.state.updateBySettingSearchTerm(to: keyword)
			}
			.assign(to: &$state)
		
		didClearSearchTag
			.compactMap(weak: self) { this, tagId in
				this.state.recentSearches.first(where: { $0.id == tagId })?.id
			}
			.compactMap(weak: self) { this, tagId in
				this.state.updateByClearingSearchTag(by: tagId)
			}
			.assign(to: &$state)
	}
	
	private func setupTransitionBindings() {
		didReceiveTransition
			.compactMap(weak: self) { this, data in
				this.state.with { $0.transitionData = .init(data: data) }
			}
			.assign(to: &$state)
		
		let didTap = didTapGame.mapToVoid()
			.map { true }
		
		let didDismiss = handleGameDetailResult
			.map { false }
		
		didTap.merge(with: didDismiss)
			.compactMap(weak: self) { this, shouldPresent in
				this.state.with { $0.isDetailPresented = shouldPresent }
			}
			.assign(to: &$state)
	}
	
	// MARK: - Fetch
	
	func fetchData() async {
		await getSearchTerms()
	}
	
	private func getSearchTerms() async {
		let keywords = await userPreferences.searchKeywords
		state = state.updateBySettingSearchTags(keywords)
	}
	
	private func getSearchResults(by searchTerm: String, isLoadingMore: Bool) async {
		let searchTerm = searchTerm.trimmingWhitespace()
		state = state.searchResultsLoading(isLoadingMore: isLoadingMore)
		do {
			let model = try await isLoadingMore == false
			? service.find(by: searchTerm)
			: service.findMore(of: searchTerm)
			state = state.searchResultsSuccess(
				with: model,
				searchTerm: searchTerm,
				cache: cache
			)
		} catch let serviceError as GenericRequestErrorResponse {
			state = state.searchResultsError(serviceError)
		} catch {
			state = state.updateFetchState(to: .empty)
		}
	}
	
	private func fetchImage(for game: SearchViewState.GameItem) async {
		if let image = await service.loadImage(for: game.coverURL) {
			state = state.updateBySetting(image: image, for: game)
		}
	}
}

// MARK: - Factory

extension SearchViewModel {
	private func makeTransition() -> AnyPublisher<ViewTransitionData, Never> {
		Publishers.Merge(willBeginViewTransition, didBeginViewTransition)
			.eraseToAnyPublisher()
	}
	
	private func makeOpenGameDetail() -> AnyPublisher<GameDetailViewData, Never> {
		didTapGame
			.compactMap(weak: self) { this, item in
				.init(
					entity: .entityId(item.id),
					presentation: .custom
				)
			}
			.eraseToAnyPublisher()
	}
}
