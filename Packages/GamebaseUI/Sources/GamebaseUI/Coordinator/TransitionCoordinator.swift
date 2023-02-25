import Combine
import GBFoundation

public protocol TransitionLinker: AnyObject {
	func setupTransition(
		linking source: AnyPublisher<ViewTransitionData, Never>,
		to destination: PassthroughSubject<ViewTransitionData, Never>
	)
}

public extension TransitionLinker where Self: CombineCancellableHolder {
	func setupTransition(
		linking source: AnyPublisher<ViewTransitionData, Never>,
		to destination: PassthroughSubject<ViewTransitionData, Never>
	) {
		source
			.subscribe(destination)
			.store(in: &cancellables)
	}
}

// A special coordinator that links custom swiftui transition/animatable data between two views
public typealias TransitionCoordinator<Result> = Coordinator<Result> & TransitionLinker


