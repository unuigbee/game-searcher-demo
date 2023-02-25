import SwiftUI

struct SearchTagItemView: View {
	let tag: String
	let didTapHandler: (() -> Void)
	let didClearTagHandler: (() -> Void)
	
	var body: some View {
		HStack {
			HStack(spacing: 15) {
				Image(systemName: "clock.arrow.circlepath")
					.resizable()
					.frame(width: 20, height: 20)
				Text(tag)
					.font(.body)
					.foregroundColor(.gray)
			}
			Spacer()
			Button(action: didClearTagHandler) {
				Image(systemName: "xmark.circle")
					.resizable()
			}
			.frame(width: 20, height: 20)
			.accentColor(.black)
		}
		.contentShape(Rectangle())
		.onTapGesture(perform: didTapHandler)
	}
}
