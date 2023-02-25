import Foundation
public protocol UserDefaultsStoring {
	func store<V: StorablePropertyListValue>(_ value: V, forKey key: String)
	func retrieveValue<V: StorablePropertyListValue>(forKey key: String) -> V?
	func deleteValue(forKey key: String)
	func updateValue<V: StorablePropertyListValue>(_ value: V, forKey key: String)
}

public extension UserDefaultsStoring {
	func store<V: StorablePropertyListValue, Key: RawRepresentable>(
		_ value: V,
		forKey key: Key
	) where Key.RawValue == String {
		store(value, forKey: key.rawValue)
	}
	
	func retrieve<V: StorablePropertyListValue, Key: RawRepresentable>(
		forKey key: Key
	) -> V? where Key.RawValue == String {
		retrieveValue(forKey: key.rawValue)
	}
	
	func updateValue<V: StorablePropertyListValue, Key: RawRepresentable>(
		_ value: V,
		forKey key: Key
	) where Key.RawValue == String {
		updateValue(value, forKey: key.rawValue)
	}
}

