import Foundation
import Combine
import UIKit

public final class DefaultProtectedUserDefaultsStorage: AsyncValueStoring {
	private let storage: any UserDefaultsStoring
	private let notificationCenter: NotificationCenter
	private let isProtectedDataAvailable = CurrentValueSubject<Bool, Never>(false)
	private let protectedDataDidBecomeAvailableNotification: NSNotification.Name
	private let	protectedDataWillBecomeUnavailableNotification: NSNotification.Name
	private var cancellables: [AnyCancellable] = []
	
	public init(
		storage: any UserDefaultsStoring,
		notificationCenter: NotificationCenter,
		protectedDataDidBecomeAvailableNotification: NSNotification.Name,
		protectedDataWillBecomeUnavailableNotification: NSNotification.Name,
		isProtectedDataAvailable: Bool = false
	) {
		self.storage = storage
		self.notificationCenter = notificationCenter
		self.protectedDataDidBecomeAvailableNotification = protectedDataDidBecomeAvailableNotification
		self.protectedDataWillBecomeUnavailableNotification = protectedDataWillBecomeUnavailableNotification
		self.isProtectedDataAvailable.send(isProtectedDataAvailable)
		
		setupBindings()
	}
	
	private func setupBindings() {
		Publishers.Merge(
			notificationCenter
				.publisher(for: protectedDataDidBecomeAvailableNotification)
				.map { _ in true },
			notificationCenter
				.publisher(for: protectedDataWillBecomeUnavailableNotification)
				.map { _ in false }
		)
		.receive(on: DispatchQueue.main)
		.subscribe(isProtectedDataAvailable)
		.store(in: &cancellables)
	}
	
	public func store<V: StorablePropertyListValue>(_ value: V, forKey key: String) async throws {
		try await protect { [storage] in
			storage.store(value, forKey: key)
		}
	}
	
	public func retrieveValue<V: StorablePropertyListValue>(forKey key: String) async throws -> V? {
		try await protect { [storage] in
			storage.retrieveValue(forKey: key)
		}
	}
	
	public func deleteValue(forKey key: String) async throws {
		try await protect { [storage] in
			storage.deleteValue(forKey: key)
		}
	}

	public func updateValue<V: StorablePropertyListValue>(_ value: V, forKey key: String) async throws {
		try await protect { [storage] in
			storage.updateValue(value, forKey: key)
		}
	}
	
	private func protect<T>(_ block: @escaping () -> T) async throws -> T {
		if isProtectedDataAvailable.value {
			return block()
		}
		var cancellable: AnyCancellable?
		return await withCheckedContinuation { continuation in
			cancellable = isProtectedDataAvailable
				.first(where: { $0 })
				.sink { _ in
					let result = block()
					continuation.resume(with: .success(result))
					cancellable?.cancel()
				}
		}
	}
}
