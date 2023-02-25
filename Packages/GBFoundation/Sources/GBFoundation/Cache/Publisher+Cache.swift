import Foundation
import Combine

extension Publisher {
	public func cache<Key, Item>(
		key: Key,
		type cache: AnyCache<Key, Item>
	) -> Publishers.HandleEvents<Self>
	where Self.Output == Item  {
		self.handleEvents(receiveOutput: { output in
			cache.insert(output, for: key)
		})
	}
	
	public func cache<Key, Item: Collection>(
		key: Key,
		type cache: AnyCache<Key, Item>,
		limit: Int = 10
	) -> Publishers.HandleEvents<Self>
	where Self.Output == Item {
		self.handleEvents(receiveOutput: { output in
			let limitedOutput = Array(output.prefix(limit))
			let item = limitedOutput as? Item
			cache.insert(item, for: key)
		})
	}
	
	public func cache<Item: Collection>(
		withTypeOf cache: AnyCache<Item.Element.ID, Item.Element>
	) -> Publishers.HandleEvents<Self>
	where Self.Output == Item, Item.Element: Identifiable {
		self.handleEvents(receiveOutput: { output in
			output.forEach({ item in
				cache.insert(item, for: item.id)
			})
		})
	}
		
	public func cache<Item>(
		withTypeOf cache: AnyCache<Item.ID, Item>
	) -> Publishers.HandleEvents<Self>
	where Self.Output == Item, Item: Identifiable {
		self.handleEvents(receiveOutput: { output in
			cache.insert(output, for: output.id)
		})
	}

	// MARK: - Optionals
	public func cache<Key, Item>(
		key: Key,
		type cache: AnyCache<Key, Item>
	) -> Publishers.HandleEvents<Self>
	where Self.Output == Optional<Item>  {
		self.handleEvents(receiveOutput: { output in
			cache.insert(output, for: key)
		})
	}
	
	public func cache<Key, Item: Collection>(
		key: Key,
		type cache: AnyCache<Key, Item>,
		limit: Int = 10
	) -> Publishers.HandleEvents<Self>
	where Self.Output == Optional<Item> {
		self.handleEvents(receiveOutput: { output in
			let limitedOutput = output?.prefix(limit).map { $0 }
			let item = limitedOutput as? Item
			cache.insert(item, for: key)
		})
	}
}

extension Publisher where Self.Output: CacheType, Self.Failure == Never {
	public func item(for key: Self.Output.Key) -> AnyPublisher<Self.Output.Item, Never> {
		self.flatMap { cache -> AnyPublisher<Self.Output.Item, Never> in
			guard let cache = cache.item(for: key) else {
				return .empty()
			}
			
			return Just(cache)
				.eraseToAnyPublisher()
		}
		.eraseToAnyPublisher()
	}
}
