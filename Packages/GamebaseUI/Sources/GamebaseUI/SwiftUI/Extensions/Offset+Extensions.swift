import SwiftUI

public extension View  {
	func offset(width: CGFloat) -> some View {
		offset(.init(width: width, height: .zero))
	}
	
	func offset(height: CGFloat) -> some View {
		offset(.init(width: .zero, height: height))
	}
}
