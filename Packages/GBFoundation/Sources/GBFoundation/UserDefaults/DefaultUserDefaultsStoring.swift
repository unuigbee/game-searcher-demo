import Foundation

public final class DefaultUserDefaultsStorage: UserDefaultsStoring {
	// MARK: - Dependencies
	
	private let storage: UserDefaults
	
	// MARK: - Init
	
	public init(storage: UserDefaults) {
		self.storage = storage
	}
	
	// MARK: - UserDefaultsStoring
	
	public func store<V: StorablePropertyListValue>(_ value: V, forKey key: String) {
		storage.set(value, forKey: key)
	}
	
	public func retrieveValue<V: StorablePropertyListValue>(forKey key: String) -> V? {
		storage.value(forKey: key) as? V
	}
	
	public func deleteValue(forKey key: String) {
		storage.removeObject(forKey: key)
	}
	
	public func updateValue<V: StorablePropertyListValue>(_ value: V, forKey key: String) {
		storeOrUpdate(value, forKey: key)
	}
	
	private func storeOrUpdate<V: StorablePropertyListValue>(_ value: V, forKey key: String) {
		if let optional = value as? AnyOptional, optional.isNil {
			storage.removeObject(forKey: key)
		} else {
			storage.set(value, forKey: key)
		}
	}
}
