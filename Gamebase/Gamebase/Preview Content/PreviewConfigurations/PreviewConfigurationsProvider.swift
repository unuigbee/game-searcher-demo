//
//  PreviewConfigurationsProvider.swift
//  Gamebase
//
//  Created by Emmanuel Unuigbe on 10/06/2021.
//

import SwiftUI

protocol PreviewConfigurationsProvider {
	associatedtype Content: View
	associatedtype _Previews = View
	
	@ViewBuilder static var configuredPreviews: Self._Previews { get }
	static var configurations: [PreviewConfiguration<Content>] { get }
}

extension PreviewConfigurationsProvider {
	static var configuredPreviews: some View {
		ForEach(0..<configurations.count, id: \.self) { index in
			configurations[index].preview
		}
	}

	static var uniqueGameID: Int {
		return UUID().hashValue
	}
}

//protocol ScrollableData {
//	var offset: CGFloat { get }
//	var minOffset: CGFloat { get }
//	var maxOffset: CGFloat { get }
//	
//	var percentage: CGFloat { get }
//}

//var offset: CGFloat = .zero
//var minOffset: CGFloat = .zero
//var maxOffset: CGFloat = .zero
//
//var percentage: CGFloat {
//	let offset = max(self.minOffset, offset)
//	return max(offset, maxOffset)/maxOffset
//}

