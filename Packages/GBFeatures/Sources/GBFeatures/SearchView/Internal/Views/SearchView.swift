import Foundation
import Components
import GamebaseUI
import SwiftUI

public struct SearchView<DetailView: View>: View {
	// MARK: - Dependencies
	
	@ObservedObject private var viewModel: SearchViewModel
	private let detailView: DetailView
	
	// MARK: - Props
	
	@Namespace var namespace
	@FocusState private var isFocused: Bool
	
	@State private var geometryState: SearchViewGeometryState = .initial
	
	// MARK: - Init
	
	public init(viewModel: SearchViewModel, detailView: DetailView) {
		self.viewModel = viewModel
		self.detailView = detailView
	}
	
	public var body: some View {
		ZStack(alignment: .top) {
			Color.white.ignoresSafeArea()
			content
		}
		.task { await viewModel.fetchData() }
		.onAppear {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
				withAnimation {
					geometryState.shouldContractSearchBar.toggle()
					isFocused.toggle()
				}
			}
		}
	}
	
	private var content: some View {
		VStack(spacing: 16) {
			renderSearchField()
			renderSearchResultsContainer()
		}
		.matchedModalEffect(
			id: geometryState.source.id,
			namespace: namespace,
			sourceViewFrame: geometryState.source.bounds,
			isPresented: $viewModel.state.isDetailPresented,
			transitionStyle: .growMove,
			onViewTransition: viewModel.didBeginViewTransition.send,
			destination: { detailView }
		)
	}
	
	// MARK: - Search Bar
	
	private func renderSearchField() -> some View {
		HStack(alignment: .center, spacing: 8) {
			TextField("Search", text: $viewModel.state.searchTerm)
				.focused($isFocused)
				.textFieldStyle(
					.rounded(
						withLeadingIcon: .system("magnifyingglass"),
						progress: viewModel.state.isSearching ? 1.0 : nil,
						clearTextHandler: viewModel.state.isSearchEmpty ? nil : viewModel.didClearSearch.send
					)
				)
				.frame(
					width: geometryState.shouldContractSearchBar ? nil : viewModel.state.transitionData.sourceFrame.width,
					height: viewModel.state.transitionData.sourceFrame.height
				)
				
			cancelButton
		}
		.padding(.horizontal(16))
	}
	
	@ViewBuilder 
	private var cancelButton: some View {
		if geometryState.shouldContractSearchBar {
			Button("Cancel") {
				withAnimation {
					geometryState.shouldContractSearchBar.toggle()
					isFocused.toggle()
				}
				
				DispatchQueue.main.asyncAfter(
					deadline: .now() + 0.4,
					execute: viewModel.didTapDismiss.send
				)
			}
			.foregroundColor(Color.black)
			.buttonStyle(.plain)
			.frame(height: 30)
		}
	}

	// MARK: - Search Results
	
	private func renderSearchResultsContainer() -> some View {
		GeometryReader { proxy in
			ZStack(alignment: .top) {
				renderSearchList(proxy)
				renderRecentSearches()
			}
		}
		.onPreferenceChange(ItemGeometryPreferencesKey.self) { geometryState.cache = $0 }
	}
	
	@ViewBuilder
	private func renderRecentSearches() -> some View {
		if geometryState.shouldContractSearchBar && viewModel.state.canShowRecentSearches {
			VStack(alignment: .leading, spacing: 17) {
				ForEach(viewModel.state.recentSearches) { search in
					SearchTagItemView(
						tag: search.keyword,
						didTapHandler: { viewModel.didTapSearchTag.send(search.id) },
						didClearTagHandler: { viewModel.didClearSearchTag.send(search.id) }
					)
				}
			}
			.padding(.horizontal(16))
		}
	}
	
	private func renderSearchList(_ proxy: GeometryProxy) -> some View {
		ScrollView {
			LazyVStack(spacing: 8) {
				ForEach(viewModel.state.items) { item in
					renderGame(for: item)
						.anchorPreference(
							key: ItemGeometryPreferencesKey.self,
							value: .bounds,
							transform: { [.init(id: item.id, bounds: proxy[$0])] }
						)
				}
				
				nextPageLoadingView
			}
			.animation(.default, value: viewModel.state.items)
			.clipped()
			.padding(.horizontal(16))
		}
		.disabled(viewModel.state.isDetailPresented)
	}
	
	private func renderGame(for item: SearchViewState.GameItem) -> some View {
		ZStack(alignment: .bottom) {
			ImageRendererView(
				image: item.image,
				content: getImageContent
			)
			.frame(height: 100)
			.overlay(Color.black.opacity(0.2))
			.onAppear { viewModel.didActionImageLoading.send(item) }
			
			if item.coverURL == nil {
				Text(item.title.capitalizingFirstLetter())
					.font(.system(size: 30, weight: .bold))
					.lineLimit(1)
					.foregroundColor(.white)
					.padding(.init(top: 0, leading: 16, bottom: 8, trailing: 16))
			}
		}
		.clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
		.contentShape(Rectangle())
		.onTapGesture { didTapGame(for: item) }
		.matchedGeometryEffect(id: item.id, in: namespace)
	}
	
	private func getImageContent(_ image: Image) -> some View {
		image
			.resizable()
			.scaledToFill()
	}
	
	// MARK: - Helpers
	
	@ViewBuilder private var nextPageLoadingView: some View {
		if viewModel.state.canLoadMore {
			ProgressView(value: 1.0, total: 1.0)
				.progressViewStyle(.circular)
				.frame(width: 20, height: 20)
				.onAppear(perform: viewModel.didActionLoadMore.send)
		}
	}
	
	private func didTapGame(for item: SearchViewState.GameItem) {
		isFocused = false
		if let itemData = geometryState.cache.first(where: { $0.id == item.id }) {
			geometryState.source = .init(
				id: itemData.id,
				bounds: itemData.bounds
			)
			viewModel.willBeginViewTransition.send(.initial(sourceRect: itemData.bounds))
		}
		viewModel.didTapGame.send(item)
	}
}
