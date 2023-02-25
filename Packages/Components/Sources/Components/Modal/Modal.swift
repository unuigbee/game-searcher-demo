import SwiftUI
import GamebaseUI

struct Modal<Destination: View>: ViewModifier {
	typealias D = () -> Destination
	
	// MARK: - Depedencies

	@Binding private var isPresented: Bool
	private let config: Config
	private var onViewTransition: ((ViewTransitionData) -> Void)?
	private let destination: D
	
	// MARK: - Props
	
	@State private var shouldCommitPresentation: Bool = false
	@State private var shouldBeginTransition: Bool = false
	
	// MARK: - Init
	
	init(
		_ isPresented: Binding<Bool>,
		config: Config,
		onViewTransition: ((ViewTransitionData) -> Void)? = nil,
		destination: @escaping D
	) {
		self._isPresented = isPresented
		self.config = config
		self.onViewTransition = onViewTransition
		self.destination = destination
	}
	
	public func body(content: Content) -> some View {
		ZStack(alignment: .bottom) {
			content
			GeometryReader { renderEffectView(safeArea: $0.safeAreaInsets) }
				.zIndex(1)
		}
		.onChange(of: isPresented, perform: handlePresentation)
	}
	
	@ViewBuilder
	private func renderEffectView(safeArea: EdgeInsets) -> some View {
		if shouldCommitPresentation {
			destination()
				.animatableDataProvider(
					percentage: shouldBeginTransition ? 1 : 0,
					dataProvider: { didReceiveAnimatableData($0, safeArea: safeArea) }
				)
				.matchedGeometryEffect(
					id: shouldBeginTransition == false ? config.source.id : UUID().hashValue,
					in: config.source.namespace,
					isSource: false
				)
				.frame(height: UIScreen.main.bounds.height)
				.onAppear {
					withAnimation(config.transitionStyle == .none ? .none : .linear) {
						shouldBeginTransition = true
					}
				}
				.transition(activeTransition)
		}
	}
	
	private func didReceiveAnimatableData(_ data: Double, safeArea: EdgeInsets) {
		let data = ViewTransitionData(
			animatableData: data,
			sourceViewFrame: config.source.frame,
			safeArea: safeArea
		)
		
		onViewTransition?(data)
	}
	
	private func handlePresentation(_ isPresented: Bool) {
		guard isPresented else {
			dismiss()
			return
		}
		shouldCommitPresentation = true
	}
	
	private func dismiss() {
		switch config.transitionStyle {
		case .none:
			shouldCommitPresentation = false
			shouldBeginTransition = false
		case .growShrink:
			withAnimation(.spring()) {
				shouldBeginTransition = false
			}
			
			// We need to allow the view to finish shrinking before
			// commiting to removing the presented view, so we add a delay.
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
				shouldCommitPresentation = false
			}
		case .growMove:
			withAnimation(.linear) {
				shouldCommitPresentation = false
				shouldBeginTransition = false
			}
		}
	}
	
	private var activeTransition: AnyTransition {
		switch config.transitionStyle {
		case .growMove:
			return .growMove
		case .growShrink:
			return .growShrink
		case .none:
			return .none
		}
	}
}

extension Modal {
	struct Config: Hashable {
		let source: Source
		let transitionStyle: TransitionStyle
		
		struct Source: Hashable {
			let id: Int
			let namespace: Namespace.ID
			let frame: CGRect
		}
	}
}

public enum TransitionStyle {
	case none
	case growMove
	case growShrink
}

private extension AnyTransition {
	static let growMove = AnyTransition.asymmetric(
		insertion: .identity, removal: .move(edge: .bottom)
	)
	
	static let growShrink = AnyTransition.identity
	
	static let none = AnyTransition.asymmetric(
		insertion: .offset(), removal: .offset()
	)
}

public extension View {
	/// Presents view with a custom transition that starts by matching its geometry with a provided source view,
	/// exposes the current transition state so that presented view can sync itself with the transition.
	///
	///	Source views need to have `matchedGeometryEffect` modifier applied to itself to ensure geometry matching.
	///
	/// - Parameters:
	///   - id: Identifier of the source view to match
	///   - namespace: Namespace of the source view to match
	///   - sourceViewFrame: Frame of the source view to match
	///   - isPresented: A binding to a Boolean value that determines whether to present the modal that you create in the modifier's `destination` closure.
	///   - transitionStyle: The transition style of the modal transition
	///   - onViewTransition: Closure that gets called anytime transition state changes
	///   - destination: A closure that returns the content of the modal.
	
	func matchedModalEffect<Content: View>(
		id: Int,
		namespace: Namespace.ID,
		sourceViewFrame: CGRect,
		isPresented: Binding<Bool>,
		transitionStyle: TransitionStyle = .growMove,
		onViewTransition: ((ViewTransitionData) -> Void)? = nil,
		destination: @escaping () -> Content
	) -> some View {
		self.modifier(
			Modal(
				isPresented,
				config: .init(
					source: .init(
						id: id,
						namespace: namespace,
						frame: sourceViewFrame
					),
					transitionStyle: transitionStyle
				),
				onViewTransition: onViewTransition,
				destination: destination
			)
		)
	}
}
