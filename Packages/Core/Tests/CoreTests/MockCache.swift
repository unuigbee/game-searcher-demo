//
//  MockCache.swift
//  GamebaseTests
//
//  Created by Emmanuel Unuigbe on 11/07/2021.
//

import Utility

public final class MockCache<Key: Hashable, Item>: CacheType {
	private var cache: [Key: Item] = [:]
	
	public func insert(_ item: Item?, for key: Key) {
		cache[key] = item
	}
	
	public func removeItem(for key: Key) {
		cache.removeValue(forKey: key)
	}
	
	public func item(for key: Key) -> Item? {
		return cache[key]
	}
	
	public subscript(key: Key) -> Item? {
		get {
			item(for: key)
		}
		set {
			insert(newValue, for: key)
		}
	}
}

extension AnyCache where Key: Hashable {
	public static var mock: Self {
		let cache = MockCache<Self.Key, Self.Item>()
		return cache.eraseToAnyCache()
	}
}
