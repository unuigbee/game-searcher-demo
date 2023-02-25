import SwiftUI

extension HeaderScrollView {
	struct ViewState: Equatable {
		var contentOffset: CGPoint
		var rootViewFrame: CGRect
		var initialRootViewPosition: CGFloat?
		var currentRootViewFrame: CGRect
		var isViewShrinking: Bool
	}
}

extension HeaderScrollView.ViewState {
	static var initial: Self {
		.init(
			contentOffset: .zero,
			rootViewFrame: .zero,
			currentRootViewFrame: .zero,
			isViewShrinking: false
		)
	}
}
