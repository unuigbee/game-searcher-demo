import Combine
import Foundation
import GBFoundation

@MainActor
final class RemoteImageRendererViewModel: ObservableObject, CombineCancellableHolder {
	private let service: RemoteImageRendererViewService
	@Published private(set) var state: RemoteImageRendererViewState
	
	init() {
		self.service = RemoteImageRendererViewService(cache: .shared)
		self.state = .initial
		self.setupAsyncObservers()
	}
	
	private func setupAsyncObservers() {
		setUpProgressUpdatesObserver()
	}
	
	func refreshData(url: URL?, isProgressive: Bool, shouldCacheImage: Bool) async {
		guard let url else { return }
		if isProgressive {
			await fetchImageProgressively(with: url)
		} else {
			await fetchImage(with: url, shouldCacheImage: shouldCacheImage)
		}
	}
	
	private func fetchImage(with url: URL, shouldCacheImage: Bool) async {
		state = state.with { $0.fetchState = .loading }
		do {
			let image = try await service.image(
				for: url,
				shouldCacheImage: shouldCacheImage
			)
			state = state.with {
				$0.image = image
				$0.fetchState = .success
				$0.progress = 0.0
			}
		} catch {
			state = state.with { $0.fetchState = .error }
		}
	}
	
	private func fetchImageProgressively(with url: URL) async {
		state = state.with { $0.fetchState = .loading }
		do {
			let model = try await service.imageWithProgress(for: url) //URL(string: "https://picsum.photos/4000/2000")!)
			state = state.with {
				$0.image = model.image
				$0.fetchState = .success
				$0.progress = model.info.progress
			}
		} catch {
			state = state.with { $0.fetchState = .error }
		}
	}
	
	private func setUpProgressUpdatesObserver() {
		Task { [weak self] in
			guard var progressObserver = self?.service.progressUpdated.makeAsyncIterator() else {
				return
			}

			while let (image, percentage) = await progressObserver.next() {
				state = state.with {
					$0.image = image
					$0.progress = percentage
				}
			}
		}
		.store(in: &cancellables)
	}
}
