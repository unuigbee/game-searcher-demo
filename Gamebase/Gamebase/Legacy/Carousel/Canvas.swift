//
//  Canvas.swift
//  Gamebase
//
//  Created by Emmanuel Unuigbe on 28/07/2021.
//

import Foundation
import SwiftUI

struct Canvas<Content : View> : View {
	let content: Content
	
	@inlinable init(@ViewBuilder _ content: () -> Content) {
		self.content = content()
	}
	
	var body: some View {
		content
			.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
	}
}
