import UIKit
import Foundation
import Combine
import GamebaseUI
import GBFoundation

typealias Progress = (image: UIImage?, percentage: Double)

actor RemoteImageRendererViewService {
	private let cache: AnyCache<URL, UIImage>
	private(set) var model: RemoteImageRendererViewServiceModel = .empty()
	private let didUpdateProgress = PassthroughSubject<Progress, Never>()
	
	nonisolated var progressUpdated: AsyncPublisher<AnyPublisher<Progress, Never>> {
		let progressUpdate = didUpdateProgress
			.eraseToAnyPublisher()
		return AsyncPublisher(progressUpdate)
	}
	
	init(cache: AnyCache<URL, UIImage>) {
		self.cache = cache
	}
	
	public func image(for url: URL, shouldCacheImage: Bool) async throws -> UIImage? {
		if let image = cache[url] { return image }
		
		let (data, _) = try await URLSession.shared.data(from: url)
		
		let image = UIImage(data: data)
		
		if shouldCacheImage {
			cache.insert(image, for: url)
		}
		
		return image
	}
	
	public func imageWithProgress(
		for url: URL
	) async throws -> RemoteImageRendererViewServiceModel {
		if let image = cache[url] {
			model = model.settingImage(with: image)
			return model
		}
		
		model = model.updatingInfo(with: url, progress: 0.0)
		
		let (bytes, urlResponse) = try await URLSession.shared.bytes(from: url)
		
		var asyncIterator = bytes.makeAsyncIterator()
		
		let estimatedSize: Int64 = 1_000_000
		let length = urlResponse.expectedContentLength
		let size = length > 0 ? length : estimatedSize
		
		var accumulator = ByteAccumulator(name: url.absoluteString, size: Int(size))
		
		while accumulator.checkCompleted() == false {
			while accumulator.isBatchCompleted == false, let byte = try await asyncIterator.next() {
				accumulator.append(byte)
			}
			
			let progress = accumulator.progress
			let data = accumulator.data

			await updateProgress(url: url, progress: progress, data: data)
			
			// print(accumulator.description)
		}
		
		model = model.settingImage(with: accumulator.data)
		cache.insert(model.image, for: url)
		
		return model
	}
	
	@MainActor
	private func updateProgress(url: URL, progress: Double, data: Data) async {
		didUpdateProgress.send((UIImage(data: data), progress))
	}
}

// MARK: - Service model

struct RemoteImageRendererViewServiceModel: Hashable, Then {
	var info: DownloadInfo
	var image: UIImage?
	
	static func empty() -> Self {
		.init(
			info: .init(id: "", progress: 0.0),
			image: nil
		)
	}
}

extension RemoteImageRendererViewServiceModel {
	struct DownloadInfo: Identifiable, Hashable {
		let id: String
		let progress: Double
	}
}

extension RemoteImageRendererViewServiceModel {
	func updatingInfo(with url: URL, progress: Double) -> Self {
		with { $0.info = .init(id: url.absoluteString, progress: progress) }
	}
	
	func updatingImage(using data: Data, url: URL, progress: Double) -> Self {
		with {
			$0.info = .init(id: url.absoluteString, progress: progress)
			$0.image = UIImage(data: data)
		}
	}
	
	func settingImage(with data: Data) -> Self {
		with {
			$0.image = UIImage(data: data)
			$0.info = .init(id: $0.info.id, progress: 1.0)
		}
	}
	
	func settingImage(with image: UIImage) -> Self {
		with { $0.image = image }
	}
}
