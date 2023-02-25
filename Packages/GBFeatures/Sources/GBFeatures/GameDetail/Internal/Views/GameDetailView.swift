import SwiftUI
import GamebaseUI
import Components

public struct GameDetailView: View {
	// MARK: - Dependencies
	
	@ObservedObject private var viewModel: GameDetailViewModel
	
	// MARK: - Props
	
	@Namespace var namespace
	@State private var geometryState: GameDetailViewGeometryState = .initial
	
	// MARK: - Init
	
	public init(viewModel: GameDetailViewModel) {
		self.viewModel = viewModel
	}
	
	// MARK: - Views
	
	public var body: some View {
		GeometryReader { proxy in
			ZStack(alignment: .top) {
				Color.white.ignoresSafeArea()
				content(proxy)
				loader
			}
			.overlay(alignment: .top, content: toolbar)
			// TODO: Fix me - header image gets clipped when you quickly scroll up after transition
			.clipShape(
				RoundedRectangle(
					cornerRadius: changeInCornerRadius(from: 20),
					style: .continuous
				)
			)
			.edgesIgnoringSafeArea(.top)
			.task { await viewModel.refreshData() }
		}
		.fullScreenImageViewer(
			$viewModel.state.selectedScreenshots.urls,
			imageFocus: $viewModel.state.selectedScreenshots.focusIndex,
			byMatchingSource: .init(
				id: geometryState.source.id,
				namespace: namespace,
				rect: geometryState.source.bounds
			)
		)
	}
	
	private func content(_ proxy: GeometryProxy) -> some View {
		HeaderScrollView(
			header: getHeader,
			content: { getGameInfo(proxy) },
			onScroll: headerDidScroll,
			config: .init(
				behaviour: .sticky,
				isScrollEffectsEnabled: !viewModel.state.isTransitioning,
				isHeaderCollapsible: true,
				headerHeight: heightForTransitionEffect()
			)
		)
	}
	
	private func toolbar() -> some View {
		HStack(alignment: .bottom) {
			Spacer(minLength: 32)
			headerTitle
			dismissButton
		}
		.padding(.bottom, 16)
		.padding(.horizontal, 16)
		.frame(maxWidth: .infinity, maxHeight: geometryState.collaspsibleHeaderHeight)
	}
	
	private func getGameInfo(_ proxy: GeometryProxy) -> some View {
		VStack(alignment: .leading, spacing: 20) {
			Unwrap(viewModel.state.item) {
				title(for: $0)
			}
			.padding(.horizontal(16))
			
			// render carousel when transition is over
			if viewModel.state.isTransitioning == false {
				Unwrap(viewModel.state.item?.screenshots.nilIfEmpty) {
					renderCarousel(for: $0, using: proxy)
				}
			}

			Unwrap(viewModel.state.item?.description) {
				overview(with: $0)
			}
			.padding(.horizontal(16))
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(.bottom, 500)
		.padding(.top, 20)
		.background(Color.white)
	}
	
	private func title(for item: GameDetailViewState.GameItem) -> some View {
		VStack(alignment: .leading, spacing: 10) {
			Text(item.title)
				.font(.title2)
				.lineLimit(1)
				.foregroundColor(Color.black)
				.observingFrame($geometryState.titleRect)
			
			renderBodyText(item.publisher, lineLimit: 1)
		}
	}
	
	private func overview(with description: String?) -> some View {
		Unwrap(description) { overview in
			VStack(alignment: .leading, spacing: 10) {
				Text("Overview")
					.font(.subheadline)
					.lineLimit(1)
				
				renderBodyText(overview)
			}
		}
	}
	
	private func getHeader() -> some View {
		Unwrap(viewModel.state.item) { game in
			ImageRendererView(
				image: game.cover,
				content: { getHeaderImage($0) }
			)
			.blur(radius: (1 - geometryState.headerVisibility) * 5, opaque: true)
			.overlay(Color.black.opacity(0.2))
			.clipped()
		}
	}
	
	// TODO: Maybe inject header title into `HeaderScrollView` to get proper title position tracking
	private var headerTitle: some View {
		GeometryReader { proxy in
			Unwrap(viewModel.state.item) {
				Text($0.title)
					.lineLimit(1)
					.font(.subheadline)
					.foregroundColor(.white)
					.position(
						x: proxy.frame(in: .local).midX,
						y: max(navBarCenter, geometryState.titleRect.midY)
					)
					.opacity(headerTitleOpacity)
			}
		}
	}
	
	private func renderCarousel(for imageURLs: [URL], using proxy: GeometryProxy) -> some View {
		ScrollViewReader { reader in
			ScrollView(.horizontal, showsIndicators: false) {
				HStack(spacing: 10) {
					ForEach(Array(zip(imageURLs.indices, imageURLs)), id: \.0) { index, url in
						renderScreenshot(for: url, at: index)
							.anchorPreference(
								key: ItemGeometryPreferencesKey.self,
								value: .bounds,
								transform: { [.init(id: index, bounds: proxy[$0])] }
							)
					}
				}
				.padding(.horizontal(16))
			}
			.onPreferenceChange(ItemGeometryPreferencesKey.self) { geometryState.cache = $0 }
			.onChange(of: viewModel.state.selectedScreenshots.focusIndex) {
				handleImageFocusChange($0,  reader: reader)
			}
		}
	}
	
	private func renderScreenshot(for url: URL, at index: Int) -> some View {
		RemoteImage(url)
			.resizable()
			.scaledToFit()
			.frame(width: 300, height: 170)
			.contentShape(Rectangle())
			.onTapGesture {
				if let itemData = geometryState.cache.first(where: { $0.id == index }) {
					geometryState.source = .init(id: itemData.id, bounds: itemData.bounds)
				}
				viewModel.didTapScreenshot.send(index)
			}
			.matchedGeometryEffect(id: index, in: namespace)
	}
	
	private func renderBodyText(_ text: String?, lineLimit: Int? = nil) -> some View {
		Unwrap(text) { text in
			Text(text)
				.font(.footnote)
				.lineLimit(lineLimit)
				.foregroundColor(.gray)
		}
	}
	
	private func getHeaderImage(_ image: Image) -> some View {
		image
			.resizable()
			.scaledToFill()
	}
	
	private var dismissButton: some View {
		Button(action: viewModel.didTapDismiss.send) {
			Image(systemName: "xmark")
				.resizable()
				.scaledToFit()
				.frame(width: 15, height: 15)
				.foregroundColor(Color.black)
		}
		.padding(5)
		.background(
			RoundedRectangle(cornerRadius: 5.0, style: .continuous)
				.foregroundColor(.white.opacity(0.3))
		)
		.opacity(viewModel.state.transitionData.animationProgress)
	}
	
	// MARK: Loading View
	
	@ViewBuilder
	private var loader: some View {
		if viewModel.state.hasItem == false && viewModel.state.fetchState.isLoading {
			renderShimmer()
		}
	}
	
	private func renderShimmer() -> some View {
		VStack(alignment: .leading, spacing: 20) {
			ShimmerView(config: .init(cornerRadius: 0))
				.frame(height: 400)
			
			VStack(alignment: .leading, spacing: 20) {
				VStack(alignment: .leading, spacing: 10) {
					ShimmerView(config: .init(cornerRadius: 0))
						.frame(width: 250, height: 10)
					ShimmerView(config: .init(cornerRadius: 0))
						.frame(width: 150, height: 8)
					ShimmerView(config: .init(cornerRadius: 0))
						.frame(width: 150, height: 8)
				}
				
				ShimmerView(config: .init(cornerRadius: 0))
					.frame(height: 350)
			}
		}
		.edgesIgnoringSafeArea(.top)
	}
}

// MARK: - Helpers

extension GameDetailView {
	
	private var navBarCenter: CGFloat {
		geometryState.collaspsibleHeaderHeight - geometryState.titleRect.height
	}
	
	private var headerTitleOpacity: CGFloat {
		(geometryState.titleRect.midY + 7) > geometryState.collaspsibleHeaderHeight ? 0 : 1
	}
	
	private func heightForTransitionEffect() -> CGFloat {
		let startingHeight = viewModel.state.transitionData.sourceFrame.height
		let endHeight: CGFloat = 400
		let animationProgress = viewModel.state.transitionData.animationProgress
		return (endHeight - startingHeight) * animationProgress + startingHeight
	}
	
	private func changeInCornerRadius(from cornerRadius: Double) -> Double {
		return cornerRadius * (1 - viewModel.state.transitionData.animationProgress)
	}
	
	private func handleImageFocusChange(_ focusIndex: Int, reader: ScrollViewProxy) {
		guard viewModel.state.selectedScreenshots.urls?.isEmpty == false else {
			return
		}
		
		guard let imageURLs = viewModel.state.item?.screenshots else {
			return
		}
		
		let isLast = focusIndex >= imageURLs.count - 1
		let adjustedTrailingEdge: UnitPoint = .init(
			x: UnitPoint.trailing.x * 0.8,
			y: UnitPoint.trailing.y
		)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
			reader.scrollTo(
				focusIndex,
				anchor: isLast ? adjustedTrailingEdge : .center
			)
		}
	}
	
	private func headerDidScroll(
		_ offset: CGPoint,
		headerVisibiltyRatio: CGFloat,
		collaspsibleHeaderHeight: CGFloat
	) {
		geometryState.headerVisibility = headerVisibiltyRatio
		geometryState.scrollOffset = offset.y
		geometryState.collaspsibleHeaderHeight = collaspsibleHeaderHeight
	}
}
