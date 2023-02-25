import Foundation
import Combine

public extension Error {
	func publisher<T>() -> AnyPublisher<T, Self> {
		return Fail(error: self).eraseToAnyPublisher()
	}
	
	func failure<T>() -> AnyPublisher<T, Error> {
		Fail(error: self).eraseToAnyPublisher()
	}
}
