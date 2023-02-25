////
////  GameDetailView+ScrollEffects.swift
////  Gamebase
////
////  Created by Emmanuel Unuigbe on 28/05/2021.
////
//
//import Foundation
//import SwiftUI
//import Utility
//
//extension GameDetailView {
//	struct ScrollEffectsHelper {
//		private let scaledImageHeaderHeight: CGFloat = Constants.scaledImageHeaderHeight
//		private let collapsedHeaderHeight: CGFloat = Constants.collapsedHeaderHeight
//		private let parralaxMagnitude: CGFloat = Constants.parralaxMagnitude
//
//		// Since this view can presented within a custom modal view at full screen, we need to handle the case
//		// of our modal ignoring the top safe area of it's parent view.
//		private let ignoredContainerEdgeInsets: EdgeInsets
//		private let animationGeometryProperties: ModalGeometryEffect.AnimationGeometryProperties
//		private let scrollViewYOffset: CGFloat
//		private let headerImagePadding: CGFloat = Constants.headerImagePadding
//
//		private var sourceViewSize: CGSize {
//			return animationGeometryProperties.sourceViewFrame.size
//		}
//
//		private var animatableData: CGFloat {
//			return animationGeometryProperties.animatableData
//		}
//
//		private var sizeOfNonCollapsedHeader: CGFloat {
//			let headerHeight = (scaledImageHeaderHeight + ignoredContainerEdgeInsets.top)
//			let collapsedHeaderHeight = (self.collapsedHeaderHeight + ignoredContainerEdgeInsets.top/2)
//
//			return headerHeight - collapsedHeaderHeight
//		}
//
//		init(
//			animationGeometryProperties: ModalGeometryEffect.AnimationGeometryProperties = .init(),
//			scrollViewYOffset: CGFloat,
//			ignoredContainerEdgeInsets: EdgeInsets
//		) {
//			self.animationGeometryProperties = animationGeometryProperties
//			self.ignoredContainerEdgeInsets = ignoredContainerEdgeInsets
//			self.scrollViewYOffset = scrollViewYOffset
//		}
//
//		// stretchy header effect
//		func getHeightForHeaderImage(height: CGFloat) -> CGFloat {
//			let offset = scrollViewYOffset
//
//			let imageHeight = height
//
//			if offset > 0 {
//				return imageHeight + offset + headerImagePadding
//			}
//
//			return imageHeight + headerImagePadding
//		}
//
//		// > 0 == pulling/scrolling down
//		// < 0 == pulling/scrolling up
//
//		func getOffsetForHeader() -> CGFloat {
//			let offset = scrollViewYOffset
//
//			if offset < 0 && offset >= -sizeOfNonCollapsedHeader {
//				return offset / parralaxMagnitude
//			}
//
//			if offset < -sizeOfNonCollapsedHeader {
//				let imageOffset = abs(min(-sizeOfNonCollapsedHeader, offset))
//
//				return imageOffset - sizeOfNonCollapsedHeader - headerImagePadding
//			}
//
//			if offset > 0 {
//				return -offset
//			}
//
//			return 0
//		}
//
//		// blur effect
//		func getBlurRadius(proxy: GeometryProxy, rootProxy: GeometryProxy) -> CGFloat {
//			guard animationGeometryProperties.animationDidComplete else { return 0.0 }
//
//			// Normalise/Adjust the header view maxY (proxy.frame(in: .global).maxY) so it's relative
//			// to the origin.y (rootProxy.frame(in: .global).origin.y) of the game detail view.
//			// If the view is within a full screen modal origin.y is 0.0 and
//			// if not full screen, it is [X] amount of points below the top of the screen or .
//			let headerViewOffset = proxy.frame(in: .global).maxY - rootProxy.frame(in: .global).origin.y
//
//			let headerHeight = proxy.size.height
//
//			// blur will range from 0 - 1
//			let blur = (headerHeight - max(headerViewOffset, 0)) / headerHeight
//
//			let blurRadius: CGFloat = headerViewOffset > headerHeight ? 30 : 6
//
//			// Bug Fix: At specific blur ranges, applying a blur causes a black underline to appear
//			// below the blurred view, so we reset the blur to 0 as a fix.
//			let difference = abs((headerHeight - headerViewOffset))
//			if (0...5).contains(difference) {
//				return 0.0
//			}
//
//			return abs(blur) * blurRadius
//		}
//
//		// header title animation
//		func getHeaderTitleOffset(_ proxy: GeometryProxy, imageRect: CGRect, titleRect: CGRect) -> CGFloat {
//			let origin = proxy.frame(in: .global).origin.y
//			// Since we are presenting this view within a modal whose origin.y might be greater than 0,
//			// we adjust/offset the origin.y of our image and title rect by this amount to return the correct
//			// y values so it's relative to the origin.y of this current view and not the modal.
//
//			let adjustedHeaderRect = CGRect(origin: .init(x: imageRect.origin.x, y: imageRect.origin.y - origin),
//											size: imageRect.size)
//
//			let adjustedTitleRect = CGRect(origin: .init(x: titleRect.origin.x, y: titleRect.origin.y - origin),
//										   size: titleRect.size)
//			let currentYPos = adjustedTitleRect.midY
//
//			if currentYPos < adjustedHeaderRect.maxY {
//				let minYValue: CGFloat = 20.0
//				let maxYValue = collapsedHeaderHeight + ignoredContainerEdgeInsets.top
//				let currentYValue = currentYPos
//				let percentage = max(-1, (currentYValue - maxYValue) / (maxYValue - minYValue))
//				let finalOffset: CGFloat = -35.0
//
//				return 20 - (percentage * finalOffset)
//			}
//
//			return .infinity
//		}
//
//		func getDismissButtonOpacity() -> Double {
//			let offset = scrollViewYOffset
//
//			if offset <= 0 && offset < -sizeOfNonCollapsedHeader {
//				return 1.0
//			}
//
//			return 0.70
//		}
//
//		func getHeaderTitleOpacity(_ proxy: GeometryProxy, imageRect: CGRect, titleRect: CGRect) -> Double {
//			let origin = proxy.frame(in: .global).origin.y
//
//			let adjustedHeaderRect = CGRect(
//				origin: .init(x: imageRect.origin.x, y: imageRect.origin.y - origin),
//				size: imageRect.size
//			)
//
//			let adjustedTitleRect = CGRect(
//				origin: .init(x: titleRect.origin.x, y: titleRect.origin.y - origin),
//				size: titleRect.size
//			)
//
//			let currentYPos = adjustedTitleRect.midY
//
//			if currentYPos < adjustedHeaderRect.maxY {
//				let minYValue: CGFloat = 20.0
//				let maxYValue = collapsedHeaderHeight + ignoredContainerEdgeInsets.top
//				let currentYValue = currentYPos
//
//				let opacity = min(1, abs((currentYValue - maxYValue) / (maxYValue - minYValue)))
//
//				return Double(opacity)
//			}
//
//			return 1
//		}
//
//		var shouldClipHeader: Bool {
//			let offset = scrollViewYOffset
//
//			if offset <= 0 && offset >= -sizeOfNonCollapsedHeader {
//				return true
//			} else {
//				return false
//			}
//		}
//
//		var dismissButtonYPos: CGFloat {
//			// We want to center out dismiss button so it's in-line with the center of the header text or collapsed header
//			let minYValue: CGFloat = 20.0
//			let maxYValue = collapsedHeaderHeight + ignoredContainerEdgeInsets.top
//
//			let collapsedHeaderMinY: CGFloat = minYValue/2
//			let collapsedHeaderMaxY: CGFloat = maxYValue/2
//
//			return collapsedHeaderMaxY - collapsedHeaderMinY
//		}
//
//		// TODO: Move out of ScrollEffects struct
//		func getRefreshViewYPos(_ proxy: GeometryProxy, dismissButtonRect: CGRect) -> CGFloat {
//			let origin = proxy.frame(in: .global).origin.y
//
//			let adjustedDismissButtonRect = CGRect(
//				origin: .init(x: dismissButtonRect.origin.x, y: dismissButtonRect.origin.y - origin),
//				size: dismissButtonRect.size
//			)
//
//			return adjustedDismissButtonRect.origin.y + dismissButtonRect.height + ignoredContainerEdgeInsets.top/2
//		}
//
//		var refreshViewYPos: CGFloat {
//			// Center the refresh view at the center of the dismissButton
//			return dismissButtonYPos + dismissButtonYPos/2
//		}
//	}
//}
//
//extension GameDetailView {
//	struct Constants {
//		static let screenshotSize = URLImageSizeFormatter.screenShotMedium.dimension
//		static let collapsedHeaderHeight: CGFloat = 60
//		static let scaledImageHeaderHeight: CGFloat = screenshotSize.height * 0.7
//		static let headerImagePadding: CGFloat = 20
//		static let parralaxMagnitude: CGFloat = 9
//	}
//}
