import Foundation
import Combine

public enum CombineWeakifyError: Error {
	case objectDisposed
}

extension Publisher {
	// MARK: - tryMap

	public func tryMap<A: AnyObject, Result>(weak obj: A, selector: @escaping (A, Output) throws -> Result) -> Publishers.TryMap<Self, Result> {
		tryMap { [weak obj] value -> Result in
			guard let obj = obj else {
				throw CombineWeakifyError.objectDisposed
			}
			return try selector(obj, value)
		}
	}

	// MARK: - Map

	public func mapToVoid() -> Publishers.Map<Self, Void> {
		map { _ in () }
	}

	// MARK: - compactMap

	public func compactMap<A: AnyObject, Result>(weak obj: A, selector: @escaping (A, Output) -> Result?) -> Publishers.CompactMap<Self, Result> {
		compactMap { [weak obj] value -> Result? in
			guard let obj = obj else {
				return nil
			}
			return selector(obj, value)
		}
	}

	// MARK: - flatMap

	public func flatMap<A: AnyObject, P: Publisher>(weak obj: A, selector: @escaping (A) -> P) -> AnyPublisher<P.Output, P.Failure> where Failure == P.Failure {
		flatMap { [weak obj] _ -> AnyPublisher<P.Output, P.Failure> in
			guard let obj = obj else { return .empty() }
			return selector(obj).eraseToAnyPublisher()
		}
		.eraseToAnyPublisher()
	}

	public func flatMap<A: AnyObject, P: Publisher>(weak obj: A, selector: @escaping (A, Output) -> P) -> AnyPublisher<P.Output, P.Failure> where Failure == P.Failure {
		flatMap { [weak obj] value -> AnyPublisher<P.Output, P.Failure> in
			guard let obj = obj else { return .empty() }
			return selector(obj, value).eraseToAnyPublisher()
		}
		.eraseToAnyPublisher()
	}
}

extension Publisher where Output: OptionalType {
	public func compactMap<Result>() -> Publishers.CompactMap<Self, Result> where Result == Output.Wrapped {
		compactMap(\.value)
	}
}
