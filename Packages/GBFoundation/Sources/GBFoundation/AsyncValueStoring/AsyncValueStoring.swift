import Foundation

public protocol AsyncValueStoring {
	func store<V: StorablePropertyListValue>(_ value: V, forKey key: String) async throws
	func retrieveValue<V: StorablePropertyListValue>(forKey key: String) async throws -> V?
	func deleteValue(forKey key: String) async throws
	func updateValue<V: StorablePropertyListValue>(_ value: V, forKey key: String) async throws
}

public extension AsyncValueStoring {
	func store<V: StorablePropertyListValue, Key: RawRepresentable>(
		_ value: V,
		forKey key: Key
	) async throws where Key.RawValue == String {
		try await store(value, forKey: key.rawValue)
	}
	
	func retrieveValue<V: StorablePropertyListValue, Key: RawRepresentable>(
		forKey key: Key
	) async throws -> V? where Key.RawValue == String {
		try await retrieveValue(forKey: key.rawValue)
	}
	
	func updateValue<V: StorablePropertyListValue, Key: RawRepresentable>(
		_ value: V,
		forKey key: Key
	) async throws where Key.RawValue == String {
		try await updateValue(value, forKey: key.rawValue)
	}
	
	func deleteValue<Key: RawRepresentable>(
		forKey key: Key
	) async throws where Key.RawValue == String {
		try await deleteValue(forKey: key.rawValue)
	}
}

public extension AsyncValueStoring {
	func store<V: RawRepresentable>(
		_ value: V,
		forKey key: String
	) async throws where V.RawValue == StorablePropertyListValue {
		try await store(value.rawValue, forKey: key)
	}
	
	func updateValue<V: RawRepresentable>(
		_ value: V,
		forKey key: String
	) async throws where V.RawValue == StorablePropertyListValue {
		try await updateValue(value.rawValue, forKey: key)
	}
}

public extension AsyncValueStoring {
	func store<V: RawRepresentable, Key: RawRepresentable>(
		_ value: V,
		forKey key: Key
	) async throws where Key.RawValue == String, V.RawValue == StorablePropertyListValue {
		try await store(value.rawValue, forKey: key.rawValue)
	}
	
	func updateValue<V: RawRepresentable, Key: RawRepresentable>(
		_ value: V,
		forKey key: Key
	) async throws where Key.RawValue == String, V.RawValue == StorablePropertyListValue {
		try await updateValue(value.rawValue, forKey: key.rawValue)
	}
}
