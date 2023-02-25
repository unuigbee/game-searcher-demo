import SwiftUI
import GamebaseUI

public struct HeaderScrollView<Header: View, Content: View>: View {
	public typealias ScrollAction = (
		_ offset: CGPoint,
		_ headerVisibleRatio: CGFloat,
		_ collaspsibleHeaderHeight: CGFloat
	) -> Void
	
	// MARK: Dependencies
	
	@ViewBuilder private let header: () -> Header
	@ViewBuilder private let content: () -> Content
	private let onScroll: ScrollAction?
	private let config: HeaderScrollViewConfig
	
	// MARK: Props
	
	private let parralaxAffectedPadding: CGFloat = 30
	// TODO: - inject as top safe area inset
	private let collapsibleHeaderHeight: CGFloat = 88
	
	private var headerPadding: CGFloat {
		guard config.behaviour == .parralax else {
			return .zero
		}
		switch config.parralaxSmoothness {
		case .high:
			return parralaxAffectedPadding
		case .medium:
			return parralaxAffectedPadding + 15
		case .low:
			return parralaxAffectedPadding + 25
		}
	}
	
	private var headerVisibleRatio: CGFloat {
		max(0, (config.headerHeight + state.contentOffset.y) / config.headerHeight)
	}
	
	private var willCollapseHeader: Bool {
		let headerCollapsibleRatio = collapsibleHeaderHeight / config.headerHeight
		return headerVisibleRatio < headerCollapsibleRatio && config.isHeaderCollapsible
	}
	
	@State private var state: ViewState
	
	// MARK: Init
	
	public init(
		header: @escaping () -> Header,
		content: @escaping () -> Content,
		onScroll: ScrollAction? = nil,
		config: HeaderScrollViewConfig
	) {
		self.header = header
		self.content = content
		self.onScroll = onScroll
		self.config = config
		state = .initial
	}

	// MARK: - Views

	public var body: some View {
		GeometryReader { proxy in
			ZStack(alignment: .top) {
				scrollView(proxy)
				navbarOverlay
			}
			.animation(
				config.behaviour == .sticky ? nil : .linear.speed(2.0),
				value: willCollapseHeader
			)
		}
		.navigationBarTitleDisplayMode(.inline)
		.prefersNavigationBarBackgroundHidden()
		.observingFrame($state.rootViewFrame)
	}
	
	@ViewBuilder
	var navbarOverlay: some View {
		if willCollapseHeader {
			renderNavBarOverlay()
		}
	}
	
	@ViewBuilder
	private func renderNavBarOverlay() -> some View {
		if config.behaviour == .sticky {
			Color.clear
				.frame(height: collapsibleHeaderHeight)
				.overlay(
					header().frame(height: config.headerHeight),
					alignment: .bottom
				)
				.ignoresSafeArea(edges: .top)
		} else {
			Color.clear
				.frame(height: collapsibleHeaderHeight)
				.background(.thinMaterial)
				.ignoresSafeArea(edges: .top)
		}
	}
	
	private func scrollView(_ rootGeometry: GeometryProxy) -> some View {
		ScrollView(showsIndicators: false) {
			ZStack(alignment: .top) {
				contentOffsetMarker
				VStack(spacing: .zero) {
					header(rootGeometry)
					content(rootGeometry)
				}
			}
		}
		// useful disabling scrolling while view is undergoing custom view transitions
		.disabled(!config.isScrollEffectsEnabled)
		.onPreferenceChange(ContentOffsetPreferenceKey.self) {
			onScroll?($0, headerVisibleRatio, collapsibleHeaderHeight)
			state.contentOffset = $0
		}
		.onChange(of: state.rootViewFrame) {
			updateByValidatingViewShrinkage(rootViewRect: $0)
			updateByCachingInitialRootViewPosition($0, from: rootGeometry)
		}
	}
	
	private var contentOffsetMarker: some View {
		GeometryReader { geometry in
			Color.clear
				.preference(
					key: ContentOffsetPreferenceKey.self,
					value: geometry.frame(in: .global).origin
				)
		}
		.frame(width: 0, height: 0)
	}
	
	private func header(_ rootGeometry: GeometryProxy) -> some View {
		GeometryReader { localGeometry in
			let viewProperties = dynamicHeaderViewProperties(
				from: localGeometry,
				rootGeometry: rootGeometry
			)
			
			header()
				.frame(width: viewProperties.width, height: viewProperties.headerHeight)
				.offset(y: viewProperties.headerOffset)
		}
		.frame(height: config.headerHeight)
	}

	private func content(_ geometry: GeometryProxy) -> some View {
		ZStack(alignment: .top) {
			if config.behaviour == .stickyOffset || config.behaviour == .parralax {
				Color.clear
					.frame(height: maximumHeightRequiredToReachTop(geometry))
			}

			content()
		}
	}
}

// MARK: - Helpers

extension HeaderScrollView {
	private func maximumHeightRequiredToReachTop(_ geometry: GeometryProxy) -> CGFloat {
		let bottomSafeArea: CGFloat

		if geometry.safeAreaInsets.bottom == 0 {
			bottomSafeArea = geometry.safeAreaInsets.top
		} else {
			bottomSafeArea = geometry.safeAreaInsets.bottom
		}

		return geometry.size.height + geometry.safeAreaInsets.top + bottomSafeArea
	}
	
	// Helps determine how we should handle scroll offsets based on whether the screen is
	// presented fullscreen or not
	private func isFullScreen(rootGeometry: GeometryProxy) -> Bool {
		let rootViewMinY = rootGeometry.frame(in: .global).minY
		let rootViewTopSafeArea = rootGeometry.safeAreaInsets.top

		let difference = rootViewMinY - rootViewTopSafeArea
		
		return difference == 0
	}
	
	private func normalizedMinY(localGeometry: GeometryProxy, rootGeometry: GeometryProxy) -> CGFloat {
		let minY = localGeometry.frame(in: .global).minY

		if isFullScreen(rootGeometry: rootGeometry) == false, let initialRootMinY = state.initialRootViewPosition {
			let distanceToTop = initialRootMinY - rootGeometry.safeAreaInsets.top
			return minY - distanceToTop
		}

		return minY
	}

	private func rootViewPositionDidChange(rootGeometry: GeometryProxy) -> Bool {
		guard let initialRootViewMinY = state.initialRootViewPosition else {
			return false
		}

		return rootGeometry.frame(in: .global).minY > initialRootViewMinY
	}

	private func normalizedHeaderHeight(_ headerHeight: CGFloat) -> CGFloat {
		if config.behaviour == .parralax {
			return headerHeight + headerPadding
		} else {
			return headerHeight
		}
	}
}

// MARK: - State updates

extension HeaderScrollView {
	private func updateByCachingInitialRootViewPosition(_ rect: CGRect, from rootGeometry: GeometryProxy) {
		guard isFullScreen(rootGeometry: rootGeometry) == false else {
			return
		}

		if state.initialRootViewPosition == nil {
			state.initialRootViewPosition = rect.minY
		}
	}

	private func updateByValidatingViewShrinkage(rootViewRect: CGRect) {
		if rootViewRect.height > state.currentRootViewFrame.height {
			state.currentRootViewFrame = rootViewRect
			state.isViewShrinking = false
		} else {
			state.isViewShrinking = true
			state.currentRootViewFrame = rootViewRect
		}
	}
}

// MARK: - ViewProperties

extension HeaderScrollView {
	private struct HeaderViewProperties: Hashable {
		let width: CGFloat?
		let headerHeight: CGFloat?
		let headerOffset: CGFloat
	}
	
	private func dynamicHeaderViewProperties(
		from geometry: GeometryProxy,
		rootGeometry: GeometryProxy
	) -> HeaderViewProperties {
		if config.isScrollEffectsEnabled {
			return headerViewProperties(
				from: geometry,
				rootGeometry: rootGeometry
			)
		} else {
			let headerHeightForParralax = state.isViewShrinking
			? config.headerHeight
			: normalizedHeaderHeight(config.headerHeight)
			
			let headerHeight = config.behaviour == .parralax
			? headerHeightForParralax
			: config.headerHeight
			
			return .init(
				width: geometry.size.width,
				headerHeight: headerHeight,
				headerOffset: .zero
			)
		}
	}
	
	private func headerViewProperties(
		from geometry: GeometryProxy,
		rootGeometry: GeometryProxy
	) -> HeaderViewProperties {
		let minY = normalizedMinY(localGeometry: geometry, rootGeometry: rootGeometry)
		let hasScrolledUp = minY > 0
		var headerOffset: CGFloat = 0
		var headerHeight: CGFloat = geometry.size.height
		
		if hasScrolledUp {
			// dragging down
			if rootViewPositionDidChange(rootGeometry: rootGeometry) == false {
				headerOffset = -minY
			}
			
			// stretch height of header
			if config.behaviour == .sticky && isFullScreen(rootGeometry: rootGeometry) {
				headerHeight = geometry.size.height + minY
			} else {
				headerHeight = geometry.size.height
			}
		} else {
			// dragging up
			if config.behaviour == .stickyOffset {
				headerOffset = -minY
			} else if config.behaviour == .parralax {
				headerOffset = minY / config.parralaxSmoothness.magnitude
			}
		}
		
		// when view is being dismissed/shrinking we want to keep the header pinned to the top
		// for the sticky offset or parralax behaviour
		if state.isViewShrinking && (config.behaviour == .stickyOffset || config.behaviour == .parralax) {
			headerOffset = .zero
		}
		
		return .init(
			width: geometry.size.width,
			headerHeight: normalizedHeaderHeight(headerHeight),
			headerOffset: headerOffset
		)
	}
}

private struct ContentOffsetPreferenceKey: PreferenceKey {
	static var defaultValue: CGPoint = .zero

	static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

private extension View {
	@ViewBuilder
	func prefersNavigationBarBackgroundHidden() -> some View {
		#if os(watchOS)
		self
		#else
		if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 8.0, *) {
			self.toolbarBackground(.hidden, for: .navigationBar)
		} else {
			self
		}
		#endif
	}
}
