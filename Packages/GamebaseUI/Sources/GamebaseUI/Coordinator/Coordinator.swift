import Foundation
import Combine
import GBFoundation

public protocol AnyCoordinator: AnyObject {
	var identifier: UUID { get }
}

extension Coordinator {
	public enum DisposingStrategy {
		case onAll
		case onDispose
	}
}

@MainActor open class Coordinator<Result>: AnyCoordinator, CombineCancellableHolder {
	public typealias CoordinationResult = Result
	
	public let identifier: UUID = UUID()
	private var childCoordinators = [UUID: Any]()
	public var disposingStrategy: DisposingStrategy = .onAll
	
	public init() {}
	
	public func coordinate<T>(to coordinator: Coordinator<T>) -> AnyPublisher<T, Never> {
		store(coordinator: coordinator)
		
		let disposingBlock: (() -> Void) = { [weak self, weak coordinator] in
			guard let coordinator = coordinator else { return }
			self?.free(coordinator: coordinator)
		}
		
		switch disposingStrategy {
		case .onAll:
			return coordinator.start()
				.handleOnAll(disposingBlock)
				.eraseToAnyPublisher()
		case .onDispose:
			return coordinator.start()
				.handleOnDispose(disposingBlock)
				.eraseToAnyPublisher()
		}
	}
	
	open func start() -> AnyPublisher<CoordinationResult, Never> {
		fatalError("Start method should be implemented.")
	}
 
	private func store(coordinator: AnyCoordinator) {
		childCoordinators[coordinator.identifier] = coordinator
	}
	
	private func free(coordinator: AnyCoordinator) {
		childCoordinators.removeValue(forKey: coordinator.identifier)
	}
}

public extension Publisher {
	func handleEvents(
		receiveSubscription: ((Subscription) -> Void)? = nil,
		receiveOutput: ((Self.Output) -> Void)? = nil,
		receiveOnDispose: (() -> Void)? = nil,
		receiveRequest: ((Subscribers.Demand) -> Void)? = nil
	) -> Publishers.HandleEvents<Self> {
		handleEvents(
			receiveSubscription: receiveSubscription,
			receiveOutput: receiveOutput,
			receiveCompletion: { _ in receiveOnDispose?() },
			receiveCancel: receiveOnDispose,
			receiveRequest: receiveRequest
		)
	}

	func handleOnDispose(_ onDispose: @escaping () -> Void) -> Publishers.HandleEvents<Self> {
		handleEvents(
			receiveCompletion: { _ in onDispose() },
			receiveCancel: { onDispose() }
		)
	}

	func handleOnAll(_ onAll: @escaping (() -> Void)) -> Publishers.HandleEvents<Self> {
		handleEvents(
			receiveOutput: { _ in onAll() },
			receiveOnDispose: { onAll() }
		)
	}
}
