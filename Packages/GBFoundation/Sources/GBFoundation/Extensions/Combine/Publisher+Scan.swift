import Combine

public extension Publisher {
	func withPrevious() -> AnyPublisher<(previous: Output?, current: Output), Failure> {
		scan((Output?, Output)?.none) { ($0?.1, $1) }
			.compactMap { $0 }
			.eraseToAnyPublisher()
	}
}
