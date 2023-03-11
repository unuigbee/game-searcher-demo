import Foundation
import SwiftUI

public extension RemoteImage {
	final class Context<HoldingView: View> {
		let url: URL?
		let shouldDownloadImageProgressiveley: Bool
		let shouldCacheImage: Bool
		let enablesAnimation: Bool
		let placeholderView: (() -> PlaceholderView)?
		let onPhase: ((RemoteImagePhase) -> Void)?
		let onProgress: ((Double) -> Void)?
		
		var configurations: [(HoldingView) -> HoldingView] = []
		
		public init(
			url: URL?,
			enablesAnimation: Bool = true,
			shouldDownloadImageProgressiveley: Bool = false,
			shouldCacheImage: Bool = true,
			placeholderView: (() -> PlaceholderView)? = { EmptyView() },
			onPhase: ((RemoteImagePhase) -> Void)? = nil,
			onProgress: ((Double) -> Void)? = nil
		) {
			self.url = url
			self.enablesAnimation = enablesAnimation
			self.shouldDownloadImageProgressiveley = shouldDownloadImageProgressiveley
			self.shouldCacheImage = shouldCacheImage
			self.placeholderView = placeholderView
			self.onPhase = onPhase
			self.onProgress = onProgress
		}
	}
}
