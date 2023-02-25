//
//  BlurView.swift
//  Gamebase
//
//  Created by Emmanuel Unuigbe on 08/05/2021.
//

import SwiftUI
import UIKit

struct BlurView: View {
	@Environment(\.colorScheme) var scheme

	var active: Bool
	var onTap: () -> ()

	var body: some View {
		if active {
			VisualEffectView(effect: UIBlurEffect(style: scheme == .dark ? .dark : .light))
				.edgesIgnoringSafeArea(.all)
				.onTapGesture(perform: self.onTap)
		}
	}
}

struct VisualEffectView: UIViewRepresentable {
	var effect: UIVisualEffect?
	
	func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
		UIVisualEffectView()
	}
	
	func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
		uiView.effect = effect
	}
}

