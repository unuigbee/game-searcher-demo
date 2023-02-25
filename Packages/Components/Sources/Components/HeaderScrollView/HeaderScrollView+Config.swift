import SwiftUI

public struct HeaderScrollViewConfig {
	let behaviour: ScrollBehaviour
	let parralaxSmoothness: ParralaxSmoothness
	let headerHeight: CGFloat
	let isScrollEffectsEnabled: Bool
	let isHeaderCollapsible: Bool

	public init(
		behaviour: ScrollBehaviour,
		parralaxSmoothness: ParralaxSmoothness = .medium,
		isScrollEffectsEnabled: Bool = true,
		isHeaderCollapsible: Bool = false,
		headerHeight: CGFloat
	) {
		self.behaviour = behaviour
		self.parralaxSmoothness = parralaxSmoothness
		self.isScrollEffectsEnabled = isScrollEffectsEnabled
		self.isHeaderCollapsible = isHeaderCollapsible
		self.headerHeight = headerHeight
	}
}

public extension HeaderScrollViewConfig {
	struct ScrollBehaviour: Hashable {
		private let scrollingUp: ScrollBehaviour.Up
		private let scrollingDown: ScrollBehaviour.Down
	}
}

public extension HeaderScrollViewConfig.ScrollBehaviour {
	private enum Up: Hashable {
		case sticky
		case parralax
	}

	private enum Down: Hashable {
		case sticky
		case offset
	}

	static let sticky: Self = .init(
		scrollingUp: .sticky,
		scrollingDown: .sticky
	)

	static let stickyOffset: Self = .init(
		scrollingUp: .sticky,
		scrollingDown: .offset
	)

	static let parralax: Self = .init(
		scrollingUp: .parralax,
		scrollingDown: .offset
	)
}

public extension HeaderScrollViewConfig {
	enum ParralaxSmoothness: Hashable {
		case low
		case medium
		case high

		public var magnitude: CGFloat {
			switch self {
			case .low:
				return 5.0
			case .medium:
				return 9.0
			case .high:
				return 15.0
			}
		}
	}
}
