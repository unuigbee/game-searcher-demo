import Combine
import Foundation

public extension Publisher {
	// MARK: - Catch

	func catchJust<Result>(
		_ selector: @escaping (Failure) -> Result
	) -> AnyPublisher<Result, Never> where Output == Result {
		self.catch { error -> Just<Result> in
			Just(selector(error))
		}
		.eraseToAnyPublisher()
	}

	func `catch`<A: AnyObject, P: Publisher>(
		weak obj: A,
		selector: @escaping (A, Failure) -> P
	) -> AnyPublisher<P.Output, P.Failure> where Output == P.Output {
		self.catch { [weak obj] error -> AnyPublisher<P.Output, P.Failure> in
			guard let obj = obj else { return .empty() }
			return selector(obj, error).eraseToAnyPublisher()
		}
		.eraseToAnyPublisher()
	}

	func catchJust<A: AnyObject, Result>(
		weak obj: A,
		selector: @escaping (A, Failure) -> Result
	) -> AnyPublisher<Result, Never> where Output == Result {
		`catch`(weak: obj) { this, error in Just(selector(this, error)) }
	}
}
