import UIKit

public extension AnyCache where Key == ImageCache.Key, Item == ImageCache.Item {
	static var shared: Self {
		return ImageCache.shared.eraseToAnyCache()
	}
}

public final class ImageCache {
	static let shared = ImageCache(config: .defaultConfig)
	
	private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
		let cache = NSCache<AnyObject, AnyObject>()
		cache.countLimit = config.countLimit
		return cache
	}()
	
	private lazy var decodedImageCache: NSCache<AnyObject, AnyObject> = {
		let cache = NSCache<AnyObject, AnyObject>()
		cache.totalCostLimit = config.memoryLimit
		return cache
	}()
	
	private let config: Config
	
	public init(config: ImageCache.Config) {
		self.config = config
	}
	
	public struct Config {
		public let countLimit: Int
		public let memoryLimit: Int
		
		public static let defaultConfig = Config(countLimit: 100, memoryLimit: 1024 * 1024 * 100)
	}
	
	private func image(for url: URL) -> UIImage? {
		if let decodedImage = decodedImageCache.object(forKey: url as AnyObject) as? UIImage {
			return decodedImage
		}
		
		if let image = imageCache.object(forKey: url as AnyObject) as? UIImage {
			let decodedImage = image.decodedImage()
			decodedImageCache.setObject(image as AnyObject, forKey: url as AnyObject, cost: decodedImage.diskSize)
			return decodedImage
		}
		
		return nil
	}
	
	private func insertImage(_ image: UIImage?, for url: URL) {
		guard let image else { return removeImage(for: url) }
		let decodedImage = image.decodedImage()
		imageCache.setObject(decodedImage, forKey: url as AnyObject)
		decodedImageCache.setObject(image as AnyObject,
									forKey: url as AnyObject,
									cost: decodedImage.diskSize)
	}
	
	private func removeImage(for url: URL) {
		imageCache.removeObject(forKey: url as AnyObject)
		decodedImageCache.removeObject(forKey: url as AnyObject)
	}
}

extension ImageCache: CacheType {
	public func insert(_ item: UIImage?, for key: URL) {
		insertImage(item, for: key)
	}
	
	public func removeItem(for key: URL) {
		removeImage(for: key)
	}
	
	public func item(for key: URL) -> UIImage? {
		image(for: key)
	}
	
	public subscript(_ key: URL) -> UIImage? {
		get {
			item(for: key)
		}
		set {
			insert(newValue, for: key)
		}
	}
}

extension UIImage {
	func decodedImage() -> UIImage {
		guard let cgImage = cgImage else { return self }
		
		let size = CGSize(width: cgImage.width, height: cgImage.height)
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let context = CGContext(data: nil,
								width: Int(size.width),
								height: Int(size.height),
								bitsPerComponent: cgImage.bitsPerComponent,
								bytesPerRow: 0,
								space: colorSpace,
								bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
		
		context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
		guard let decodedImage = context?.makeImage() else { return self }
		
		return UIImage(cgImage: decodedImage)
	}
	
	var diskSize: Int {
		let byteCount = pngData()?.count ?? 0
		
		return byteCount / 1024 / 1024
	}
}

extension UIImage: NSDiscardableContent {
	public func beginContentAccess() -> Bool {
		return true
	}
	
	public func endContentAccess() {}
	
	public func discardContentIfPossible() {}
	
	public func isContentDiscarded() -> Bool {
		return false
	}
}
