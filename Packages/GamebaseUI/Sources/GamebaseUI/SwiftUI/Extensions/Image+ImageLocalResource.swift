import SwiftUI

extension Image {
	public init(with resource: ImageLocalResource) {
		switch resource {
		case let .system(name):
			self = .init(systemName: name)
		case let .name(name):
			self = .init(name)
		}
	}
}
