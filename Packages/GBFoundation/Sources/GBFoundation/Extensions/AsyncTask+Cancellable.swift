import Combine
import Foundation

/// Until a way is provided so we can bind the lifecycle of a `Task` with the lifecycle of a reference type we use the existing infrastructure of `Combine`.
public extension Task {
	private func asCancellable() -> AnyCancellable {
		.init { cancel() }
	}

	func store(in set: inout Set<AnyCancellable>) {
		asCancellable()
			.store(in: &set)
	}

	func store<C: RangeReplaceableCollection>(in collection: inout C) where C.Element == AnyCancellable {
		asCancellable()
			.store(in: &collection)
	}
}
