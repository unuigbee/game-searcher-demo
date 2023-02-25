import GBFoundation
import Foundation

public typealias GameCache = DefaultGameCache

public class DefaultGameCache: CacheType {
	public static let shared = DefaultGameCache()
	
	private let config: Config
	
	public init(config: Config = .defaultConfig) {
		self.config = config
	}
	
	private lazy var cache: NSCache<AnyObject, AnyObject> = {
		let cache = NSCache<AnyObject, AnyObject>()
		cache.countLimit = config.countLimit
		
		return cache
	}()
	
	public func insert(_ item: AppModels.Game?, for key: Int) {
		guard let game = item.flatMap(StructWrapper.init) else {
			removeItem(for: key)
			return
		}
		
		cache.setObject(game, forKey: key as AnyObject)
	}
	
	public func removeItem(for key: Int) {
		cache.removeObject(forKey: key as AnyObject)
	}
	
	public func item(for key: Int) -> AppModels.Game? {
		guard let gameWrapper = cache.object(forKey: key as AnyObject) as? StructWrapper<AppModels.Game> else {
			return nil
		}
		
		return gameWrapper.value
	}
	
	public subscript(key: Int) -> AppModels.Game? {
		get {
			item(for: key)
		}
		set {
			insert(newValue, for: key)
		}
	}
	
	public struct Config {
		public let countLimit: Int
		
		public static let defaultConfig = Config(countLimit: 100)
	}
}

public extension AnyCache where Key == GameCache.Key, Item == GameCache.Item {
	static var shared: Self {
		let cache = GameCache.shared.eraseToAnyCache()
		return cache
	}
}
