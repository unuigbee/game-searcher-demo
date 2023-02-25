import Foundation
import Combine

final class AppDriver {
	unowned let provider: Provider
	
	init(provider: Provider) {
		self.provider = provider
	}
}
