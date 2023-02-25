import Foundation
import GBFoundation

public protocol UserPreferencesStoring {
	var searchKeywords: [String] { get async }
	func setSearchKeyWords(_ value: [String]) async
}

private enum DefaultUserPreferencesStorageKeys: String {
	case searchKeywords
}

public final class DefaultUserPreferencesStorage<Storage: AsyncValueStoring>: UserPreferencesStoring {
	// MARK: - Dependencies
	
	private let storage: Storage
	
	public var searchKeywords: [String] {
		get async {
			(try? await storage.retrieveValue(usingKey: .searchKeywords)) ?? []
		}
	}
	
	// MARK: - Init
	
	public init(storage: Storage) {
		self.storage = storage
	}
	
	// MARK: - UserPreferencesStoring
	
	public func setSearchKeyWords(_ value: [String]) async {
		try? await storage.store(value, usingKey: .searchKeywords)
	}
}

 private extension AsyncValueStoring {
	func store<V: StorablePropertyListValue>(_ value: V, usingKey key: DefaultUserPreferencesStorageKeys) async throws {
		try await store(value, forKey: key)
	}
	
	func retrieveValue<V: StorablePropertyListValue>(usingKey key: DefaultUserPreferencesStorageKeys) async throws -> V? {
		try await retrieveValue(forKey: key)
	}
	
	func deleteValue(usingKey key: DefaultUserPreferencesStorageKeys) async throws {
		try await deleteValue(forKey: key)
	}
}
