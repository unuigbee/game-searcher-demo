public protocol StorageProviding: AnyProvider {
	var userPreferences: UserPreferencesStoring { get }
}

public protocol AppPreferencesStoring { }
