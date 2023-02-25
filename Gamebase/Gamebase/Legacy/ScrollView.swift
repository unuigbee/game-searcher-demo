////
////  ScrollView.swift
////  Gamebase
////
////  Created by Emmanuel Unuigbe on 26/04/2021.
////
//
//import SwiftUI
//import Combine
//import CombineSchedulers
//import UIKit
//import Services
//
//private struct ContentOffsetPreferenceKey: PreferenceKey {
//	static var defaultValue: CGPoint = .zero
//
//	static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
//}
//
//private struct ContentSizeKey: PreferenceKey {
//	static var defaultValue: CGSize = .zero
//
//	static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
//}
//
//private struct ScrollViewSizeKey: PreferenceKey {
//	static var defaultValue: CGSize = .zero
//
//	static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
//}
//
//final class ScrollViewModel: ObservableObject {
//	let didScroll = PassthroughSubject<Void, Never>()
//
//	@Published private(set) var scrolling = false
//
//	private var cancellable: AnyCancellable?
//
//	init(scheduler: AnySchedulerOf<DispatchQueue> = .main) {
//		let stopped = didScroll
//			.map { false }
//			.debounce(for: .seconds(0.2), scheduler: scheduler)
//			.eraseToAnyPublisher()
//
//		let scrolling = didScroll
//			.map { true }
//			.eraseToAnyPublisher()
//
//		cancellable = scrolling
//			.merge(with: stopped)
//			.assign(to: \.scrolling, on: self)
//	}
//}
//
//struct ScrollView<Content: View>: View {
//	let rootCoordinateSpace = String(describing: ScrollView.self)
//
//	// Modifiers
//	var showsIndicators: Bool = true
//	var isPagingEnabled: Bool = false
//	var bounces: Bool = true
//	var scrollViewDidScroll: ((ScrollViewData) -> Void)?
//	var scrollViewDidEndDecelerating: ((ScrollViewData, ScrollViewProxy) -> Void)?
//	var scrollViewDecelerationRate: UIScrollView.DecelerationRate = .normal
//	var refreshViewColor: Color = .white
//	var isRefreshViewEnabled: Bool = false
//	var refreshViewPosition: RefreshViewStartPosition = .top
//
//	// ScrollView state
//	@StateObject private var viewModel = ScrollViewModel()
//	@State private var contentSize = CGSize.zero
//	@State private var scrollViewSize = CGSize.zero
//	@State private var contentOffset = CGPoint.zero
//
//	// Twitter-Style Refresh View
//	private var offsetForRefreshViewTransition: CGFloat {
//		refreshViewPosition == .top ? 60 : 20
//	}
//
//	@State private var showRefreshView: Bool = false
//	@State private var transitionedToProgressiveView: Bool = false
//	@State private var refreshIndicatorOpacity: Double = 0.0
//	@State private var rotateRefreshIndicator: Bool = false
//
//	// init
//	private let axes: Axis.Set
//	private(set) var content: Content
//	@Binding private var shouldRefresh: Bool?
//	@Binding private var isScrollEnabled: Bool
//
//	init(axes: Axis.Set,
//		 isScrollEnabled: Binding<Bool> = .constant(true),
//		 shouldRefresh: Binding<Bool?> = .constant(nil),
//		 @ViewBuilder content: () -> Content
//	) {
//		self.axes = axes
//		self._isScrollEnabled = isScrollEnabled
//		self._shouldRefresh = shouldRefresh
//		self.content = content()
//	}
//
//	var scrollViewContent: some View {
//		return content
//	}
//
//    var body: some View {
//		ScrollViewReader { sProxy in
//			SwiftUI.ScrollView(axes, showsIndicators: showsIndicators) {
//				ZStack(alignment: axes == .horizontal ? .leading : .top) {
//					GeometryReader { geometry in
//						Color.clear
//							.preference(
//								key: ContentOffsetPreferenceKey.self,
//								value: geometry.frame(in: .named(self.rootCoordinateSpace)).origin
//							)
//					}
//					.frame(width: 0, height: 0)
//
//					content
//						.background(
//							GeometryReader { proxy in
//								Color.clear.preference(
//									key: ContentSizeKey.self,
//									value: proxy.size
//								)
//							}
//						)
//						.onPreferenceChange(ContentSizeKey.self) { value in
//							self.contentSize = value
//						}
//
//						pullToRefreshView
//							.frame(width: scrollViewSize.width, alignment: .center)
//							.offset(x: 0, y: refreshViewPosition.startPosition)
//							.onChange(of: shouldRefresh) { shouldRefresh in
//								if shouldRefresh == false {
//									onRefreshCompletion()
//								}
//							}
//				}
//				.introspectScrollView { scrollView in
//					scrollView.decelerationRate = scrollViewDecelerationRate
//					scrollView.isPagingEnabled = isPagingEnabled
//					scrollView.bounces = bounces
//				}
//			}
//			.disabled(!isScrollEnabled)
//			.background(
//				GeometryReader { proxy in
//					Color.clear.preference(
//						key: ScrollViewSizeKey.self,
//						value: proxy.size
//					)
//				}
//			)
//			.onPreferenceChange(ScrollViewSizeKey.self) { value in
//				self.scrollViewSize = value
//			}
//			.onPreferenceChange(ContentOffsetPreferenceKey.self) { value in
//				self.contentOffset = value
//			}
//			.onChange(of: contentOffset) { offset in
//				viewModel.didScroll.send()
//				scrollViewDidScroll?(
//					.init(
//						contentOffset: offset,
//						scrollViewSize: scrollViewSize,
//						contentSize: contentSize
//					)
//				)
//				handleRefreshView(from: CGFloat(offset.y))
//			}
//			.onChange(of: viewModel.scrolling) { scrolling in
//				guard scrolling == false else { return }
//				scrollViewDidEndDecelerating?(
//					.init(
//						contentOffset: contentOffset,
//						scrollViewSize: scrollViewSize,
//						contentSize: contentSize
//					),
//					sProxy
//				)
//			}
//			.coordinateSpace(name: self.rootCoordinateSpace)
//		}
//    }
//
//	@ViewBuilder private var pullToRefreshView: some View {
//		if isRefreshViewEnabled && showRefreshView && axes == .vertical {
//			Group {
//				if transitionedToProgressiveView {
//					progressiveView(1.0)
//				} else {
//					refreshIndicator
//				}
//			}
//		}
//	}
//
//	private func progressiveView(_ progress: CGFloat) -> some View {
//		ProgressView(value: progress, total: progress)
//			.progressViewStyle(CircularProgressViewStyle(tint: refreshViewColor))
//			.frame(width: 17, height: 17)
//	}
//
//	private var refreshIndicator: some View {
//		return Image(systemName: "arrow.down")
//			.resizable()
//			.scaledToFit()
//			.frame(width: 17, height: 17)
//			.foregroundColor(refreshViewColor)
//			.opacity(refreshIndicatorOpacity)
//			.rotationEffect(.degrees(rotateRefreshIndicator ? 180 : 0))
//			.animation(.linear(duration: 0.15), value: rotateRefreshIndicator)
//	}
//
//	private func handleRefreshView(from offset: CGFloat) {
//		guard isRefreshViewEnabled else { return }
//
//		func refresh(_ offset: CGFloat) {
//			if showRefreshView && offset.isZero && transitionedToProgressiveView {
//				shouldRefresh = true
//			}
//		}
//
//		func transitionToProgressiveView(from offset: CGFloat) {
//			if offset > offsetForRefreshViewTransition {
//				if rotateRefreshIndicator == false {
//					rotateRefreshIndicator = true
//				}
//
//				DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
//					if transitionedToProgressiveView == false {
//						UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//					}
//				}
//
//				DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//					transitionedToProgressiveView = true
//				}
//			}
//		}
//
//		refresh(offset)
//
//		setRefreshIndicatorOpacity(offset)
//
//		guard offset > 0 && contentSize.height > 0 else {
//			return
//		}
//
//		showRefreshView = true
//
//		transitionToProgressiveView(from: offset)
//	}
//
//	private func setRefreshIndicatorOpacity(_ offset: CGFloat) {
//		let minOffset = min(offsetForRefreshViewTransition, offset)
//
//		refreshIndicatorOpacity = Double(minOffset/offsetForRefreshViewTransition)
//	}
//
//	private func onRefreshCompletion() {
//		showRefreshView = false
//		transitionedToProgressiveView = false
//		rotateRefreshIndicator = false
//	}
//}
//
//struct ScrollViewData {
//	let contentOffset: CGPoint
//	let scrollViewSize: CGSize
//	let contentSize: CGSize
//
//	static let zero = Self.init(
//		contentOffset: CGPoint.zero,
//		scrollViewSize: CGSize.zero,
//		contentSize: CGSize.zero
//	)
//}
//
//enum RefreshViewStartPosition {
//	case top
//	case custom(CGFloat)
//
//	var startPosition: CGFloat {
//		switch self {
//		case .top:
//			return 0
//		case .custom(let value):
//			return value
//		}
//	}
//}
//
//extension RefreshViewStartPosition: Equatable {
//	static func ==(lhs: RefreshViewStartPosition, rhs: RefreshViewStartPosition) -> Bool {
//		switch (lhs, rhs) {
//		case (.custom(let lhsValue), .custom(let rhsValue)):
//			return lhsValue == rhsValue
//		case (.top, .top):
//			return true
//		default:
//			return false
//		}
//	}
//}
