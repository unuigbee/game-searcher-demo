import SwiftUI

struct FrameGetter: View {
	@Binding private var rect: CGRect
	private let preferredCoordinateSpace: CoordinateSpace

	init(rect: Binding<CGRect>, preferredCoordinateSpace: CoordinateSpace = .global) {
		_rect = rect
		self.preferredCoordinateSpace = preferredCoordinateSpace
	}

	var body: some View {
		GeometryReader { geometry in
			Color.clear
				.preference(
					key: FramePreferenceKey.self,
					value: geometry.frame(in: preferredCoordinateSpace)
				)
		}
		.onPreferenceChange(FramePreferenceKey.self) { rect in
			self.rect = rect
		}
	}
}

private struct FramePreferenceKey: PreferenceKey {
	static var defaultValue: CGRect = .zero

	static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}

public extension View {
	func observingFrame(
		_ bindableValue: Binding<CGRect>,
		within coordinateSpace: CoordinateSpace = .global
	) -> some View {
		background(FrameGetter(rect: bindableValue, preferredCoordinateSpace: coordinateSpace))
	}
}
