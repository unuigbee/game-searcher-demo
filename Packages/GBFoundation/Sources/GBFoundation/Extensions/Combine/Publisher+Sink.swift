import Combine

public extension Publisher where Failure == Never {
	func weakAssign<T: AnyObject>(
		to keyPath: ReferenceWritableKeyPath<T, Output>,
		on object: T
	) -> AnyCancellable {
		sink { [weak object] value in
			object?[keyPath: keyPath] = value
		}
	}
	
	func assign<S: Subject>(
		on subject: S
	) -> AnyCancellable where S.Failure == Failure, S.Output == Output {
		sink { value in subject.send(value) }
	}
	
	func sink() -> AnyCancellable {
		sink { _ in }
	}

	func sink<A: AnyObject>(
		weak obj: A,
		block: @escaping (A, Output) -> Void
	) -> AnyCancellable {
		sink { [weak obj] output in
			guard let obj = obj else {
				return
			}
			block(obj, output)
		}
	}
	
	func asyncSink(
		withPriority priority: TaskPriority? = nil,
		_ block: @escaping (Output) async -> Void
	) -> AnyCancellable {
		sink { output in
			Task(priority: priority) {
				await block(output)
			}
		}
	}

	func asyncSink<A: AnyObject>(
		weak obj: A,
		withPriority priority: TaskPriority? = nil,
		block: @escaping (A, Output) async -> Void
	) -> AnyCancellable {
		sink { [weak obj] output in
			guard let obj = obj else {
				return
			}

			Task(priority: priority) {
				await block(obj, output)
			}
		}
	}
}
