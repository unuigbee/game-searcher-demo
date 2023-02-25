import SwiftUI

public struct AnimatableDataProvider<Data: VectorArithmetic>: AnimatableModifier {
	private let dataProvider: (Data) -> Void
	private var percentage: Data
	@Binding private var _animatableData: Data
	
	public var animatableData: Data {
		get { percentage }
		set { percentage = newValue }
	}
	
	public func body(content: Content) -> some View {
		content
			.onChange(of: percentage) { percentage in
				dataProvider(percentage)
				_animatableData = percentage
			}
	}
	
	public init(percentage: Data, dataProvider: @escaping (Data) -> Void) {
		self.percentage = percentage
		self.dataProvider = dataProvider
		self.__animatableData = .constant(.zero)
	}
	
	public init(percentage: Data, animatableData: Binding<Data>) {
		self.percentage = percentage
		self.__animatableData = animatableData
		self.dataProvider = { _ in }
	}
}

public extension View {
	func animatableDataProvider<Data: VectorArithmetic>(
		percentage: Data,
		dataProvider: @escaping (Data) -> Void
	) -> some View {
		modifier(AnimatableDataProvider(percentage: percentage, dataProvider: dataProvider))
	}
	
	func animatableDataProvider<Data: VectorArithmetic>(
		percentage: Data,
		animatableData: Binding<Data>
	) -> some View {
		modifier(AnimatableDataProvider(percentage: percentage, animatableData: animatableData))
	}
}
