import Combine
import Foundation

public enum AsyncCompatibilityError: Error {
	case finishedWithoutPublishingValue
}

public extension Publisher {
	func asAsync() async throws -> Output {
		var cancellable: AnyCancellable?

		return try await withCheckedThrowingContinuation { continuation in
			var publishedOutput = false

			cancellable = first()
				.sink(
					receiveCompletion: { completion in
						switch completion {
						case .finished:
							if publishedOutput == false {
								continuation.resume(
									throwing: AsyncCompatibilityError.finishedWithoutPublishingValue
								)
							}
						case let .failure(error):
							continuation.resume(throwing: error)
						}
						cancellable?.cancel()
					},
					receiveValue: { value in
						publishedOutput = true
						continuation.resume(returning: value)
					}
				)
		}
	}
}

/// Note: Please avoid using this function liberally. `Never` failures usually indicates that a `Stream` of values is expected.
/// This Function only handles the first value and then it completes.
public extension Publisher where Failure == Never {
	func asAsync() async -> Output {
		var cancellable: AnyCancellable?

		return await withCheckedContinuation { continuation in

			cancellable = first()
				.sink(
					receiveValue: { value in
						continuation.resume(returning: value)
						cancellable?.cancel()
					}
				)
		}
	}
}
