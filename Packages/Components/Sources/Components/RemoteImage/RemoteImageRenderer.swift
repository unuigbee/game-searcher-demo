import SwiftUI
import Foundation
import UIKit
import GBFoundation
import Combine

struct RemoteImageRenderer<PlaceholderView: View>: View {
	private let context: RemoteImage<PlaceholderView>.Context<Image>
	@StateObject private var viewModel: RemoteImageRendererViewModel = .init()
	
	init(context: RemoteImage<PlaceholderView>.Context<Image>) {
		self.context = context
	}
	
	var body: some View {
		ZStack {
			Group {
				if let image = viewModel.state.image {
					renderImage(image)
				} else {
					renderPlaceholder()
				}
			}
			.transition(context.enablesAnimation ? .opacity.animation(.easeIn(duration: 0.3)) : .identity)
		}
		.animation(nil, value: viewModel.state.fetchState)
		.onChange(of: viewModel.state.fetchState) { state in
			switch state {
			case .success:
				context.onPhase?(.success)
			case .error:
				context.onPhase?(.error)
			case .loading:
				context.onPhase?(.loading)
			default: break
			}
		}
		.onChange(of: viewModel.state.progress) { progress in
			context.onProgress?(progress)
		}
		.task {
			await viewModel.refreshData(
				url: context.url,
				isProgressive: context.shouldDownloadImageProgressiveley,
				shouldCacheImage: context.shouldCacheImage
			)
		}
	}
	
	private func renderImage(_ uiImage: UIImage) -> some View {
		let image = Image(uiImage: uiImage)
		
		return context.configurations.reduce(image) { current, config in
			config(current)
		}
	}
	
	@ViewBuilder
	private func renderPlaceholder() -> some View {
		if let placeholderView = context.placeholderView?() {
			placeholderView
		} else {
			Color.clear
		}
	}
}


