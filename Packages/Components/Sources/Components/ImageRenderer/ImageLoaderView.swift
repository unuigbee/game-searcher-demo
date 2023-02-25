import SwiftUI
import GBFoundation
import GamebaseUI

public struct ImageRendererView<Placeholder: View, Content: View>: View {
	private var image: UIImage?
	private var placeholder: (() -> Placeholder)?
	@ViewBuilder private var content: (Image) -> Content
	
	public init(
		image: UIImage?,
		content: @escaping (Image) -> Content,
		@ViewBuilder placeholder: @escaping () -> Placeholder
	) {
		self.image = image
		self.content = content
		self.placeholder = placeholder
	}
	
	public var body: some View {
		ZStack {
			if let image = image {
				content(Image(uiImage: image))
			} else {
				placeholderView
			}
		}
	}
	
	@ViewBuilder private var placeholderView: some View {
		if let placeholder { placeholder() }
	}
}

extension ImageRendererView where Placeholder == Color {
	public init(
		image: UIImage?,
		content: @escaping (Image) -> Content
	) {
		self.image = image
		self.content = content
		self.placeholder = { Color.gray }
	}
}

