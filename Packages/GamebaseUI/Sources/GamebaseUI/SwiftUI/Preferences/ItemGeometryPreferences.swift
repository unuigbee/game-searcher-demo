import Foundation
import SwiftUI

public struct ItemGeometryPreferencesKey: PreferenceKey {
	public typealias Value = [Data]
	
	public static var defaultValue: Value { [] }
	
	public static func reduce(
		value: inout Value,
		nextValue: () -> Value
	) {
		value.append(contentsOf: nextValue())
	}
}

extension ItemGeometryPreferencesKey {
	public struct Data: Hashable, Identifiable, Equatable {
		public var id: Int
		public var bounds: CGRect

		public init(id: Int, bounds: CGRect) {
			self.id = id
			self.bounds = bounds
		}
		
		public static func == (lhs: Self, rhs: Self) -> Bool {
			lhs.id == rhs.id
		}
	}
}
