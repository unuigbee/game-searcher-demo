import SwiftUI
import Foundation

public struct RoundedTextFieldLeadingLoaderStyle: TextFieldStyle {
	private let iconResource: ImageLocalResource
	private let cornerRadius: CGFloat
	private let progress: CGFloat?
	private let clearTextHandler: (() -> Void)?
	
	public init(
		iconResource: ImageLocalResource,
		cornerRadius: CGFloat = 7.0,
		progress: CGFloat? = nil,
		clearTextHandler: (() -> Void)? = nil
	) {
		self.iconResource = iconResource
		self.cornerRadius = cornerRadius
		self.progress = progress
		self.clearTextHandler = clearTextHandler
	}
	
	public func _body(configuration: TextField<Self._Label>) -> some View {
		HStack(alignment: .center, spacing: 10) {
			if let progress {
				progressiveView(progress)
			} else {
				icon
			}
			
			configuration
			
			Spacer()
			
			if clearTextHandler != nil {
				clearTextButton()
			}
		}
		.frame(height: 35)
		.background(Color.white)
		.overlay(
			RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
				.stroke(Color.gray, lineWidth: 1)
		)
	}
	
	private var icon: some View {
		Image(with: iconResource)
			.resizable()
			.scaledToFill()
			.frame(width: 17, height: 17)
			.padding(.leading, 10)
	}
	
	private func progressiveView(_ progress: CGFloat) -> some View {
		ProgressView(value: progress, total: 1.0)
			.progressViewStyle(CircularProgressViewStyle())
			.frame(width: 17, height: 17)
			.padding(.leading, 10)
	}
	
	private func clearTextButton() -> some View {
		Button {
			clearTextHandler?()
		} label: { () -> Image in
			Image(systemName: "xmark.circle")
				.resizable()
		}
		.accentColor(.black)
		.frame(width: 15, height: 15)
		.padding(.trailing, 10)
	}
}

extension TextFieldStyle where Self == RoundedTextFieldLeadingLoaderStyle {
	public static func rounded(
		withLeadingIcon icon: ImageLocalResource,
		progress: CGFloat? = nil,
		clearTextHandler: (() -> Void)? = nil
	) -> RoundedTextFieldLeadingLoaderStyle {
		RoundedTextFieldLeadingLoaderStyle(
			iconResource: icon,
			progress: progress,
			clearTextHandler: clearTextHandler
		)
	}
}
