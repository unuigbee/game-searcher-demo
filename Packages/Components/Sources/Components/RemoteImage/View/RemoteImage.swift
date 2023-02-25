import SwiftUI
import GBFoundation
import GamebaseUI

protocol RemoteImageProtocol: View {
	associatedtype PlaceholderView: View

	var context: RemoteImage<PlaceholderView>.Context<Image> { get set }

	init(context: RemoteImage<PlaceholderView>.Context<Image>)
}

public struct RemoteImage<PlaceholderView: View>: RemoteImageProtocol {
	var context: Context<Image>

	public init(context: Context<Image>) {
		self.context = context
	}

	public init(
		url: URL?,
		placeholderView: @escaping (() -> PlaceholderView)
	) {
		context = .init(url: url, placeholderView: placeholderView)
	}
}

public typealias RemoteImageNoPlaceholder = RemoteImage<Color>
public extension RemoteImageNoPlaceholder {
	init(_ url: URL?) {
		context = .init(url: url, placeholderView: nil)
	}
}

extension RemoteImageProtocol {
	public var body: some View {
		RemoteImageRenderer(context: context)
	}

	public func configure(_ block: @escaping (Image) -> Image) -> Self {
		context.configurations.append(block)
		return self
	}
}

public extension RemoteImage {
	func resizable(
		capInsets: EdgeInsets = EdgeInsets(),
		resizingMode: Image.ResizingMode = .stretch
	) -> RemoteImage {
		configure { $0.resizable(capInsets: capInsets, resizingMode: resizingMode) }
	}

	func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> RemoteImage {
		configure { $0.renderingMode(renderingMode) }
	}

	func interpolation(_ interpolation: Image.Interpolation) -> RemoteImage {
		configure { $0.interpolation(interpolation) }
	}

	func antialiased(_ isAntialiased: Bool) -> RemoteImage {
		configure { $0.antialiased(isAntialiased) }
	}
}
