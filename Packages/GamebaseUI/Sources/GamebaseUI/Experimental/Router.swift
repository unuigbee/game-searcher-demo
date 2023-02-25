import Combine
import Foundation
import GBFoundation
import SwiftUI

public protocol AnyRouter: AnyObject {
	var identifier: UUID { get }
}

@MainActor open class Router<Result>: AnyRouter, ObservableObject, CombineCancellableHolder {
	public typealias RoutingResult = Result
	
	// MARK: - Props
	public let identifier = UUID()
	private var childRouters = [UUID: Any]()
	
	@Published public var state: State

	public init() {
		self.state = State()
	}

	public func route<T>(to router: Router<T>) -> AnyPublisher<T, Never> {
		store(router: router)
		
		let disposingBlock: (() -> Void) = { [weak self, weak router] in
			guard let router = router else { return }
			print("### free")
			self?.dismiss()
			router.state.root = nil
			self?.free(router: router)
		}
		
		return router
			.start()
			.handleEvents(
				receiveSubscription: { [weak self, weak router] _ in
					guard let router = router else { return }
					self?.navigateTo(router.root)
				},
				receiveOutput: { _ in disposingBlock() },
				receiveCompletion: { _ in disposingBlock() },
				receiveCancel: 	disposingBlock
			)
			.eraseToAnyPublisher()
	}

	public func route<T>(
		to router: Router<T>,
		onStart: @escaping () -> Void = { }
	) -> AnyPublisher<T, Never> {
		store(router: router)
		print("### route")
		let disposingBlock: (() -> Void) = { [weak self, weak router] in
			guard let router = router else { return }
			print("### free")
			self?.dismiss()
			router.state.root = nil
			self?.free(router: router)
		}
		
		return router
			.start()
			.handleEvents(
				receiveSubscription: { _ in onStart() },
				receiveOutput: { _ in disposingBlock() },
				receiveCompletion: { _ in disposingBlock() },
				receiveCancel: disposingBlock
			)
			.eraseToAnyPublisher()
	}

	open func start() -> AnyPublisher<RoutingResult, Never> {
		fatalError("Start method should be implemented.")
	}
	
	private func store(router: AnyRouter) {
		childRouters[router.identifier] = router
	}

	private func free(router: AnyRouter) {
		print("### childRouters count before: \(childRouters.count)")
		childRouters.removeValue(forKey: router.identifier)
		print("### childRouters count after: \(childRouters.count)")
	}
}

public extension Router {
	struct State {
		public var root: AnyView?
		public var presentationContext: PresentationContext?
		public var navigating: AnyView?
		public var presenting: AnyView?
		public var isPresented: Binding<Bool>?
	}

	var root: AnyView? {
		state.root
	}

	// Bindings
	var isNavigating: Binding<Bool> {
		boolBinding(keyPath: \.navigating)
	}

	var isPresentingSheet: Binding<Bool> {
		boolBinding(keyPath: \.presenting)
	}
	
	var isPresenting: Binding<Bool> {
		boolBinding(keyPath: \.presentationContext)
	}
	
	var isPresented: Binding<Bool> {
		guard let isPresented = state.isPresented else {
			return .constant(false)
		}
		
		return isPresented
	}

	// Actions
	func navigateTo<V: View>(_ view: V) {
		//state.navigating = AnyView(view)
		state.presentationContext = .navigating(AnyView(view))
	}

	func presentSheet<V: View>(_ view: V) {
		//state.presenting = AnyView(view)
		state.presentationContext = .presenting(AnyView(view))
	}

	func setRootTo<V: View>(_ view: V) {
		state.root = AnyView(view)
	}

	func dismiss() {
		state.presentationContext = nil
		state.root = nil
	}
}

public extension Router.State {
	enum PresentationContext {
		case navigating(AnyView)
		case presenting(AnyView)
	}
}

public extension View {
	@MainActor func navigate<Result>(_ router: Router<Result>) -> some View {
		modifier(NavigatingViewModifer(presentingView: router.binding(keyPath: \.navigating)))
	}

	@MainActor func sheet<Result>(_ router: Router<Result>) -> some View {
		modifier(SheetViewModifer(presentingView: router.binding(keyPath: \.presenting)))
	}

	@MainActor func present<Result>(_ router: Router<Result>) -> some View {
		modifier(RouterModifier(presentation: router.binding(keyPath: \.presentationContext)))
	}
}

struct RouterModifier<Result>: ViewModifier {
	@Binding var presentationContext: Router<Result>.State.PresentationContext?

	init(presentation: Binding<Router<Result>.State.PresentationContext?>) {
		self._presentationContext = presentation
	}

	private var activeViewBinding: Binding<Bool> {
		Binding(
			get: { presentationContext != nil },
			set: { isPresented in
				if isPresented == false {
					presentationContext = nil
				}
			}
		)
	}

	func body(content: Content) -> some View {
		renderActivePresentation(content)
	}

	@ViewBuilder
	func renderActivePresentation(_ content: Content) -> some View {
		switch presentationContext {
		case let .presenting(view):
			content
				.sheet(isPresented: activeViewBinding) { view }
		case let .navigating(view):
			ZStack {
				NavigationLink(
					destination: view,
					isActive: activeViewBinding
				 ) { EmptyView() }

				content
			}
		case .none:
			content
		}
	}
}

struct NavigatingViewModifer: ViewModifier {
	@Binding var presentingView: AnyView?

	init(presentingView: Binding<AnyView?>) {
		self._presentingView = presentingView
	}

	private var activeViewBinding: Binding<Bool> {
		Binding(
			get: { presentingView != nil },
			set: {
				if !$0 {
					presentingView = nil
				}
			}
		)
	}

	func body(content: Content) -> some View {
		ZStack {
			NavigationLink(
				destination: presentingView,
				isActive: activeViewBinding
			 ) { EmptyView() }

			content
		}
	}
}

struct SheetViewModifer: ViewModifier {
	@Binding var presentingView: AnyView?

	init(presentingView: Binding<AnyView?>) {
		self._presentingView = presentingView
	}

	private var activeViewBinding: Binding<Bool> {
		Binding(
			get: { presentingView != nil },
			set: {
				if !$0 {
					presentingView = nil
				}
			}
		)
	}

	func body(content: Content) -> some View {
		content
			.sheet(isPresented: activeViewBinding) { presentingView }
	}
}

private extension Router {
	func binding<T>(keyPath: WritableKeyPath<State, T>) -> Binding<T> {
		Binding(
			get: { self.state[keyPath: keyPath] },
			set: { self.state[keyPath: keyPath] = $0 }
		)
	}

	func boolBinding<T>(keyPath: WritableKeyPath<State, T?>) -> Binding<Bool> {
		Binding(
			get: { self.state[keyPath: keyPath] != nil },
			set: {
				if !$0 {
					self.state[keyPath: keyPath] = nil
				}
			}
		)
	}
}
