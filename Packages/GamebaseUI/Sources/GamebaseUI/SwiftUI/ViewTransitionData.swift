import SwiftUI

public struct ViewTransitionData: Hashable, Sendable {
	public let animatableData: Double
	public let sourceViewFrame: CGRect
	public let safeArea: EdgeInsets
	
	public var isTransitionComplete: Bool {
		animatableData == 1.0
	}
	
	public init(
		animatableData: Double,
		sourceViewFrame: CGRect,
		safeArea: EdgeInsets
	) {
		self.animatableData = animatableData
		self.sourceViewFrame = sourceViewFrame
		self.safeArea = safeArea
	}
}

public extension ViewTransitionData {
	 static let empty: Self = .init(
		animatableData: .zero,
		sourceViewFrame: .zero,
		safeArea: .zero
	)
	
	static func initial(sourceRect: CGRect) -> Self {
		.init(animatableData: .zero, sourceViewFrame: sourceRect, safeArea: .zero)
	}
	
	static func complete(sourceRect: CGRect) -> Self {
		.init(animatableData: 1.0, sourceViewFrame: sourceRect, safeArea: .zero)
	}
}
