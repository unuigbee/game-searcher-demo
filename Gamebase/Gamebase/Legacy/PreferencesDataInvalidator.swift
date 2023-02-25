//
//  PreferencesDataInvalidator.swift
//  Gamebase
//
//  Created by Emmanuel Unuigbe on 31/07/2021.
//

import Foundation

protocol PreferencesDataInvalidator: Equatable {
	var invalidatingPreferencesValue: InvalidationIdentifier? { get }
}

extension PreferencesDataInvalidator {
	static func==(lhs: Self, rhs: Self) -> Bool {
		return lhs.invalidatingPreferencesValue == rhs.invalidatingPreferencesValue
	}
}
