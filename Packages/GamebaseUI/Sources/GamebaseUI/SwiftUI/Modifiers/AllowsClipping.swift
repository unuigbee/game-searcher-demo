import SwiftUI

public struct AllowsClipping: ViewModifier {
	@Binding private var allowsClipping: Bool

	public init(allowsClipping: Binding<Bool>) {
		_allowsClipping = allowsClipping
	}

	@ViewBuilder public func body(content: Content) -> some View {
		if allowsClipping {
			content
		} else {
			content
		}
	}
}

public extension View {
	func allowsClipping(_ value: Binding<Bool>) -> some View {
		modifier(AllowsClipping(allowsClipping: value))
	}

	func allowsClipping(_ value: Bool = true) -> some View {
		modifier(AllowsClipping(allowsClipping: .constant(value)))
	}
}
