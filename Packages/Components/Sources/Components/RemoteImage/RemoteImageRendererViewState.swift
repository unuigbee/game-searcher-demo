import Foundation
import UIKit
import GBFoundation

struct RemoteImageRendererViewState: Hashable, Then {
	var image: UIImage?
	var fetchState: FetchState
	var progress: Double
}

extension RemoteImageRendererViewState {
	enum FetchState: Hashable {
		case empty
		case loading
		case success
		case error
	}
}

extension RemoteImageRendererViewState {
	static let initial: Self = .init(image: nil, fetchState: .empty, progress: 0.0)
}
