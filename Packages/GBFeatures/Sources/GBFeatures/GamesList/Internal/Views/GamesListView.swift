import SwiftUI
import GamebaseUI
import GBFoundation
import Components

public struct GameListView<DetailView: View, SearchView: View>: View {
	// MARK: - Dependencies
	
	@ObservedObject private var viewModel: GamesListViewModel
	private let detailView: DetailView
	private let searchView: SearchView
	
	// MARK: - Props
	
	@Namespace private var namespace
	@Namespace private var gameNamespace
	@Namespace private var searchNamespace
	
	@State private var geometryState: GameListViewGeometryState = .initial
	
	// MARK: - Init
	
	public init(
		viewModel: GamesListViewModel,
		detailView: DetailView,
		searchView: SearchView
	) {
		self.viewModel = viewModel
		self.detailView = detailView
		self.searchView = searchView
	}
	
	public var body: some View {
		NavigationView {
			content
				.matchedModalEffect(
					id: geometryState.source.id,
					namespace: activeNameSpace(),
					sourceViewFrame: geometryState.source.bounds,
					isPresented: $viewModel.state.isDetailPresented,
					transitionStyle: geometryState.source.namespace == .game ? .growMove : .none,
					onViewTransition: viewModel.didBeginViewTransition.send,
					destination: destination
				)
		}
		.navigationBarHidden(true)
		.task { await viewModel.refreshData() }

	}
	
	private var content: some View {
		VStack(spacing: 16) {
			renderSearchField()
			renderGames()
		}
	}
	
	@ViewBuilder private func renderGames() -> some View {
		GeometryReader { proxy in
			ScrollView {
				if viewModel.state.hasGames {
					recommendedGames(using: proxy)
				} else {
					placeholderLoadingView
				}
			}
			.disabled(viewModel.state.isDetailPresented)
		}
		.onPreferenceChange(ItemGeometryPreferencesKey.self) { geometryState.cache.games = $0 }
	}
	
	private func recommendedGames(using proxy: GeometryProxy) -> some View {
		LazyVStack(spacing: 8) {
			ForEach(viewModel.state.recommended) { item in
				renderGame(from: item)
					.anchorPreference(
						key: ItemGeometryPreferencesKey.self,
						value: .bounds,
						transform: { [.init(id: item.id, bounds: proxy[$0])] }
					)
			}
			
			nextPageLoadingView
		}
		.animation(.default, value: viewModel.state.recommended)
		.clipped()
		.padding(.horizontal(16))
	}
	
	private func renderGame(from item: GamesListViewState.GameItem) -> some View {
		ZStack(alignment: .bottom) {
			ImageRendererView(
				image: item.image,
				content: getImageContent
			)
			.frame(height: 100)
			.overlay(Color.black.opacity(0.2))
			.onAppear { viewModel.didActionImageLoading.send(item) }
			
			if item.image == nil {
				Text(item.title.capitalizingFirstLetter())
					.font(.system(size: 30, weight: .bold))
					.lineLimit(1)
					.foregroundColor(.white)
					.padding(.init(top: 0, leading: 16, bottom: 8, trailing: 16))
			}
		}
		.clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
		.contentShape(Rectangle())
		.onTapGesture { openDetail(for: item) }
		.matchedGeometryEffect(id: item.id, in: gameNamespace)
	}
	
	private func getImageContent(_ image: Image) -> some View {
		image
			.resizable()
			.scaledToFill()
	}
	
	private func renderSearchField() -> some View {
		TextField("Search", text: .constant(""))
			.textFieldStyle(.rounded(withLeadingIcon: .system("magnifyingglass")))
			.observingFrame($geometryState.cache.search)
			.padding(.horizontal(16))
			.disabled(true)
			.contentShape(Rectangle())
			.onTapGesture(perform: openSearch)
			.matchedGeometryEffect(id: 1, in: searchNamespace)
	}
	
	// MARK: - Helpers
	
	private var placeholderLoadingView: some View {
		VStack(alignment: .center, spacing: 8) {
			ForEach(0..<9) { _ in
				ShimmerView(config: .init(cornerRadius: 20))
					.frame(height: 100)
			}
		}
		.padding(.horizontal(16))
	}
	
	@ViewBuilder private var nextPageLoadingView: some View {
		if viewModel.state.canLoadMore {
			ProgressView(value: 1.0, total: 1.0)
				.progressViewStyle(.circular)
				.frame(width: 20, height: 20)
				.onAppear(perform: viewModel.didActionLoadMore.send)
		}
	}
	
	private func openDetail(for item: GamesListViewState.GameItem) {
		if let itemData = geometryState.cache.games.first(where: { $0.id == item.id }) {
			geometryState.source = .init(
				id: itemData.id,
				bounds: itemData.bounds,
				namespace: .game
			)
			viewModel.willBeginViewTransition.send(.initial(sourceRect: itemData.bounds))
		}
		viewModel.didTapGame.send(item)
	}
	
	private func openSearch() {
		geometryState.source = .init(
			id: 1,
			bounds: geometryState.cache.search,
			namespace: .search
		)
		viewModel.willBeginViewTransition.send(.initial(sourceRect: geometryState.cache.search))
		viewModel.didTapSearch.send()
	}
	
	@ViewBuilder
	private func destination() -> some View {
		switch geometryState.source.namespace {
		case .empty:
			emptyView
		case .game:
			detailView
		case .search:
			searchView
		}
	}
	
	private func activeNameSpace() -> Namespace.ID {
		let activeNamespace = geometryState.source.namespace

		switch activeNamespace {
		case .empty:
			return namespace
		case .game:
			return gameNamespace
		case .search:
			return searchNamespace
		}
	}
}
