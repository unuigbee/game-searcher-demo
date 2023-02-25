import SwiftUI
import Foundation
import GamebaseUI

struct ImageCarouselViewer: View {
	// MARK: - Dependencies
	
	@State private var imageURLs: [URL]
	@Binding private var imageFocus: Int
	private let transitionData: ViewTransitionData
	private var onDismiss: (() -> Void)?
	
	// MARK: - Props
	
	private let aspectRatio: CGFloat = 30/17
	@State private var dragOffset: CGSize = .zero
	@State private var dragOffsetPredicted: CGSize = .zero
	@State private var willDismissFromOnDragEnded: Bool = false
	
	// MARK: - Init
	
	init(
		imageURLs: [URL],
		imageFocus: Binding<Int>,
		transitionData: ViewTransitionData,
		onDismiss: (() -> Void)? = nil
	) {
		self.imageURLs = imageURLs
		self._imageFocus = imageFocus
		self.transitionData = transitionData
		self.onDismiss = onDismiss
	}
	
	// MARK: - Views
	
	var body: some View {
		content()
			.overlay(alignment: .topTrailing, content: { dismissButton })
	}
	
	private func content() -> some View {
		ZStack {
			Color.black.opacity(
				transitionData.isTransitionComplete ? 1.0 : 0.0
			)
			carouselView
		}
	}
	
	private var carouselView: some View {
		renderCarousel()
	}
	
	private func renderCarousel() -> some View {
		TabView(selection: $imageFocus) {
			ForEach(Array(zip(imageURLs.indices, imageURLs)), id: \.0) { index, url in
				RemoteImage(context: .init(url: url, enablesAnimation: false))
					.resizable()
					.scaledToFit()
					.padding(.horizontal(5 * transitionData.animatableData))
					.offset(height: changeInVerticalDragOffset())
					.pinchToZoom(minScale: 1.0)
					.gesture(dragGesture)
					.tag(index)
			}
		}
		.frame(width: widthForTransitionEffect(), height: heightForTransitionEffect())
		.tabViewStyle(.page(indexDisplayMode: .never))
	}
	
	private var dismissButton: some View {
		Button(action: { onDismiss?() }) {
			Image(systemName: "xmark")
				.resizable()
				.scaledToFit()
				.frame(width: 15, height: 15)
				.foregroundColor(Color.black)
				.padding(5)
		}
		.background(
			RoundedRectangle(cornerRadius: 5.0)
				.foregroundColor(.white.opacity(0.3))
		)
		.padding(.topTrailing(50, 16))
		.opacity(transitionData.isTransitionComplete ? transitionData.animatableData : 0.0)
	}
	
	// MARK: - Drag
	
	private func dismissOnDrag() {
		willDismissFromOnDragEnded = true
		onDismiss?()
	}
	
	private var dragGesture: some Gesture {
		DragGesture(minimumDistance: 20)
			.onChanged { value in
				dragOffset = value.translation
				dragOffsetPredicted = value.predictedEndTranslation
			}
			.onEnded { _ in
				let shouldDismiss = abs(dragOffset.height) > 100
				|| (abs(dragOffsetPredicted.height) / abs(dragOffset.height) > 3)
				
				if shouldDismiss {
					withAnimation(.spring()) {
						dragOffset = dragOffsetPredicted
					}
					dismissOnDrag()
					return
				}
				
				withAnimation(.interactiveSpring()) {
					self.dragOffset = .zero
				}
			}
	}
	
	// MARK: - Transition Effects
	
	private func widthForTransitionEffect() -> CGFloat {
		let startingWidth = transitionData.sourceViewFrame.width
		let endWidth = UIScreen.main.bounds.width
		let animationProgress = transitionData.animatableData

		return (endWidth - startingWidth) * animationProgress + startingWidth
	}
	
	private func heightForTransitionEffect() -> CGFloat {
		let startingHeight = transitionData.sourceViewFrame.height
		let endHeight = UIScreen.main.bounds.height * 0.8
		let animationProgress = transitionData.animatableData

		return (endHeight - startingHeight) * animationProgress + startingHeight
	}
	
	private func changeInVerticalDragOffset() -> CGFloat {
		guard willDismissFromOnDragEnded else {
			return dragOffset.height
		}
		
		let currentOffsetHeight = dragOffset.height
		let changeInCurrentOffsetHeight = currentOffsetHeight * transitionData.animatableData
		return changeInCurrentOffsetHeight
	}
}

