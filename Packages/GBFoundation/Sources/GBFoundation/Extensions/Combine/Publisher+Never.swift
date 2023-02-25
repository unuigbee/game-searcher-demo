import Combine

public extension Publisher {
	static func never() -> AnyPublisher<Output, Failure> {
		Empty(completeImmediately: false)
			.eraseToAnyPublisher()
	}

	static func empty() -> AnyPublisher<Output, Failure> {
		Empty(completeImmediately: true)
			.eraseToAnyPublisher()
	}

	static func just(_ output: Output) -> AnyPublisher<Output, Failure> {
		Just(output)
			.setFailureType(to: Failure.self)
			.eraseToAnyPublisher()
	}
}
