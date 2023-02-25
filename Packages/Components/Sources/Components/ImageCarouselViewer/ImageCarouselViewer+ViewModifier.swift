import Foundation
import SwiftUI
import GamebaseUI

public struct ImageViewerModifier: ViewModifier {
	// MARK: - Dependencies
	
	@Binding private var imageURLs: [URL]?
	@Binding private var imageFocus: Int
	private let source: Source?
	
	// MARK: - Props
	
	@Namespace private var emptyNamespace
	@State private var transitionData: ViewTransitionData
	@State private var shouldBeginTransition: Bool = false
	private var isPresented: Bool { imageURLs != nil }
	private var isSourceMatchingAvailable: Bool { source != nil }
	private var activeNamespace: Namespace.ID { source?.namespace ?? emptyNamespace }
	
	// MARK: - Init
	
	init(
		imageURLs: Binding<[URL]?>,
		imageFocus: Binding<Int>,
		source: Source?
	) {
		self._imageURLs = imageURLs
		self._imageFocus = imageFocus
		self.source = source
		if source == nil {
			transitionData = .complete(sourceRect:  source?.rect ?? .zero)
		} else {
			transitionData = .initial(sourceRect: source?.rect ?? .zero)
		}
	}
	
	public func body(content: Content) -> some View {
		ZStack(alignment: .bottom) {
			content
			renderImageViewer()
				.zIndex(1)
		}
		.animation(.linear, value: isPresented)
	}
	
	@ViewBuilder
	private func renderImageViewer() -> some View {
		if isPresented {
			Unwrap(imageURLs) { urls in
				ImageCarouselViewer(
					imageURLs: urls,
					imageFocus: _imageFocus,
					transitionData: transitionData,
					onDismiss: onDismiss
				)
				.animatableDataProvider(
					percentage: shouldBeginTransition ? 1 : 0,
					dataProvider: didReceiveAnimatableData
				)
				.matchedGeometryEffect(
					id: shouldBeginTransition == false && isSourceMatchingAvailable
					? imageFocus
					: UUID().hashValue,
					in: activeNamespace,
					isSource: false
				)
			}
			.onAppear {
				withAnimation { shouldBeginTransition = true }
			}
			.transition(isSourceMatchingAvailable ? .identity : .opacity.animation(.easeOut))
			.edgesIgnoringSafeArea(.top)
		}
	}
	
	private func onDismiss() {
		guard isSourceMatchingAvailable else {
			shouldBeginTransition = false
			imageURLs = nil
			return
		}
		
		withAnimation { shouldBeginTransition = false }
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
			imageURLs = nil
		}
	}
	
	private func didReceiveAnimatableData(_ data: Double) {
		guard isSourceMatchingAvailable else {
			return
		}
		
		transitionData = ViewTransitionData(
			animatableData: data,
			sourceViewFrame: source?.rect ?? .zero,
			safeArea: .zero
		)
	}
}

extension ImageViewerModifier {
	public struct Source: Hashable {
		let id: Int
		let namespace: Namespace.ID
		let rect: CGRect
		
		public init(id: Int, namespace: Namespace.ID, rect: CGRect) {
			self.id = id
			self.namespace = namespace
			self.rect = rect
		}
	}
}

public extension View {
		func fullScreenImageViewer(
			_ urls: Binding<[URL]?>,
			imageFocus: Binding<Int>,
			byMatchingSource source: ImageViewerModifier.Source
		) -> some View {
			if #available(iOS 16, *) {
				return modifier(
					ImageViewerModifier(
						imageURLs: urls,
						imageFocus: imageFocus,
						source: source
					)
				)
			} else {
				return modifier(
					ImageViewerModifier(
						imageURLs: urls,
						imageFocus: imageFocus,
						source: nil
					)
				)
			}
		}

	
	func fullScreenImageViewer(
		_ urls: Binding<[URL]?>,
		imageFocus: Binding<Int>
	) -> some View {
		modifier(
			ImageViewerModifier(
				imageURLs: urls,
				imageFocus: imageFocus,
				source: nil
			)
		)
	}
}
