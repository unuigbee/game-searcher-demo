import Foundation
import UIKit
import Combine
import GBFoundation

public protocol AppImageLoaderService {
	func image(for url: URL) -> AnyPublisher<UIImage?, Never>
	func image(for url: URL) async -> UIImage?
}
	
public actor DefaultAppImageLoaderService: AppImageLoaderService {
	private let cache: AnyCacheOf<ImageCache>
	
	public init(cache: AnyCacheOf<ImageCache>) {
		self.cache = cache
	}
	
	nonisolated public func image(for url: URL) -> AnyPublisher<UIImage?, Never> {
		if let image = cache[url] { return .just(image) }
		
		return URLSession.shared
			.dataTaskPublisher(for: url)
			.map(\.data)
			.map(UIImage.init)
			.cache(key: url, type: cache)
			.replaceError(with: nil)
			.subscribe(on: DispatchQueue.global(qos: .default))
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}
	
	public func image(for url: URL) async -> UIImage? {
		if let image = cache[url] {
			return image
		}
		
		guard let (data, _) = try? await URLSession.shared.data(from: url) else {
			return nil
		}
		
		let image = UIImage(data: data)
		cache.insert(image, for: url)
		
		return image
	}
}

