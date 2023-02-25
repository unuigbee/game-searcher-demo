import Foundation
import Combine

public typealias _CacheType = CacheType

public protocol CacheType {
	associatedtype Key
	associatedtype Item: Sendable

	func insert(_ item: Item?, for key: Key)
	func removeItem(for key: Key)
	func item(for key: Key) -> Item?
	
	subscript(_ key: Key) -> Item? { get set }
}

public extension CacheType {
	func eraseToAnyCache() -> AnyCache<Key, Item> {
		AnyCache(self)
	}
	
	var publisher: AnyPublisher<Self, Never> {
		return Just(self).eraseToAnyPublisher()
	}
}

public typealias AnyCacheOf<CacheType> = AnyCache<CacheType.Key, CacheType.Item> where CacheType: _CacheType

public struct AnyCache<Key, Item>: CacheType  {
	private let _insert: (_ item: Item?, _ key: Key) -> Void
	private let _removeItem: (_ key: Key) -> Void
	private let _item: (_ key: Key) -> Item?
	
	public init<Cache: CacheType>(_ cache: Cache) where Cache.Key == Key, Cache.Item == Item {
		self._insert = { cache.insert($0, for: $1) }
		self._removeItem = { cache.removeItem(for: $0) }
		self._item = { cache.item(for: $0) }
	}
	
	public func insert(_ item: Item?, for key: Key) {
		self._insert(item, key)
	}

	public func removeItem(for key: Key) {
		self._removeItem(key)
	}

	public func item(for key: Key) -> Item? {
		self._item(key)
	}
	
	public subscript(_ key: Key) -> Item? {
		get {
			item(for: key)
		}
		set {
			insert(newValue, for: key)
		}
	}
}

//// GameCache
//public extension AnyCache where Key == GameCache.Key, Item == GameCache.Item {
//	static var shared: Self {
//		let cache = GameCache.shared.eraseToAnyCache()
//		return cache
//	}
//}
//
//// GamesCache
//public typealias GamesCache = AppDataCache<[Game], Storage<[Game]>>
//
//public extension AnyCache
//where
//	Key == AppDataCache<[Game], Storage<[Game]>>.Key,
//	Item == AppDataCache<[Game], Storage<[Game]>>.Item
//{
//	static var items: Self {
//		let storage = Storage<[Game]>.self
//		let cache = AppDataCache<[Game], Storage>(defaultItem: [], storage: storage)
//
//		return cache.eraseToAnyCache()
//	}
//}
//
//// ImageCache
//public extension AnyCache where Key == ImageCache.Key, Item == ImageCache.Item {
//	static var shared: Self {
//		return ImageCache.shared.eraseToAnyCache()
//	}
//}
//
//// SearchedKeywordsCache
//public typealias SearchedKeywordsCache = AppDataCache<[SearchKeyword], Storage<[SearchKeyword]>>
//
//public extension AnyCache
//where
//	Key == AppDataCache<[SearchKeyword], Storage<[SearchKeyword]>>.Key,
//	Item == AppDataCache<[SearchKeyword], Storage<[SearchKeyword]>>.Item
//{
//	static var keywords: Self {
//		let storage = Storage<[SearchKeyword]>.self
//		let cache = AppDataCache<[SearchKeyword], Storage>(defaultItem: [], storage: storage)
//
//		return cache.eraseToAnyCache()
//	}
//}
//
//// GenreKeywordsCache
//public typealias GenreKeywordsCache = AppDataCache<[Genre], Storage<[Genre]>>
//
//public extension AnyCache
//where
//	Key == AppDataCache<[Genre], Storage<[Genre]>>.Key,
//	Item == AppDataCache<[Genre], Storage<[Genre]>>.Item
//{
//	static var keywords: Self {
//		let storage = Storage<[Genre]>.self
//		let cache = AppDataCache<[Genre], Storage>(defaultItem: [], storage: storage)
//
//		return cache.eraseToAnyCache()
//	}
//}
