import Foundation
import SwiftUI

public struct Unwrap<Value, Content: View>: View {
	private let value: Value?
	private let content: (Value) -> Content

	public init(
		_ value: Value?,
		@ViewBuilder content: @escaping (Value) -> Content
	) {
		self.value = value
		self.content = content
	}

	public var body: some View {
		value.map(content)
	}
}
