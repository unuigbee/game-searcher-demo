//
//  ActiveItemGetter.swift
//  Gamebase
//
//  Created by Emmanuel Unuigbe on 28/07/2021.
//

import Foundation
import SwiftUI

struct ActiveItemGetter: View {
	let id: Int
	var isActiveItemCondition: (CGRect) -> Bool
	@Binding var activeItem: Int
	
	var preferencesInvalidator: InvalidationIdentifier?
	
	init(id: Int, activeItem: Binding<Int>, isActiveItemCondition: @escaping (CGRect) -> Bool) {
		self.id = id
		self._activeItem = activeItem
		self.isActiveItemCondition = isActiveItemCondition
	}
	
	var body: some View {
		GeometryReader { geometry in
			Rectangle()
				.fill(Color.clear)
				.preference(
					key: ActiveItemFramePreferenceKey.self,
					value: ActiveItemFramePreferenceData(
						rect: geometry.frame(in: .global),
						invalidatingPreferencesValue: preferencesInvalidator
					)
				)
		}
		.onPreferenceChange(ActiveItemFramePreferenceKey.self) { data in
			if isActiveItemCondition(data.rect) {
				activeItem = id
			}
		}
	}
}

private struct ActiveItemFramePreferenceKey: PreferenceKey {
	static var defaultValue: ActiveItemFramePreferenceData = .zero

	static func reduce(value: inout ActiveItemFramePreferenceData, nextValue: () -> ActiveItemFramePreferenceData) {
		value = nextValue()
	}
}

struct ActiveItemFramePreferenceData: PreferencesDataInvalidator {
	let rect: CGRect
	let invalidatingPreferencesValue: Double?
	
	static let zero = Self.init(rect: .zero, invalidatingPreferencesValue: nil)
	
	static func==(lhs: ActiveItemFramePreferenceData, rhs: ActiveItemFramePreferenceData) -> Bool {
		guard
			let lhsInvalidatingValue = lhs.invalidatingPreferencesValue,
			let rhsInvalidatingValue = rhs.invalidatingPreferencesValue
		else { return lhs.rect == rhs.rect }
		
		return lhsInvalidatingValue == rhsInvalidatingValue
	}
}
