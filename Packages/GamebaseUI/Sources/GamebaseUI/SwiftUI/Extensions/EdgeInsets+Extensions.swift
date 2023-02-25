import SwiftUI

public extension EdgeInsets {
	static func top(_ value: CGFloat) -> Self {
		EdgeInsets(top: value, leading: 0, bottom: 0, trailing: 0)
	}

	static func leading(_ value: CGFloat) -> Self {
		EdgeInsets(top: 0, leading: value, bottom: 0, trailing: 0)
	}

	static func topTrailing(_ top: CGFloat, _ trailing: CGFloat) -> Self {
		EdgeInsets(top: top, leading: 0, bottom: 0, trailing: trailing)
	}
	
	static func bottom(_ value: CGFloat) -> Self {
		EdgeInsets(top: 0, leading: 0, bottom: value, trailing: 0)
	}

	static func trailing(_ value: CGFloat) -> Self {
		EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: value)
	}

	static var zero: Self {
		.init(top: 0, leading: 0, bottom: 0, trailing: 0)
	}

	static func vertical(_ value: CGFloat) -> Self {
		EdgeInsets(top: value, leading: 0, bottom: value, trailing: 0)
	}

	static func horizontal(_ value: CGFloat) -> Self {
		EdgeInsets(top: 0, leading: value, bottom: 0, trailing: value)
	}

	static func all(_ value: CGFloat) -> Self {
		EdgeInsets(top: value, leading: value, bottom: value, trailing: value)
	}
}

extension EdgeInsets: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(leading)
		hasher.combine(trailing)
		hasher.combine(top)
		hasher.combine(bottom)
	}
}
