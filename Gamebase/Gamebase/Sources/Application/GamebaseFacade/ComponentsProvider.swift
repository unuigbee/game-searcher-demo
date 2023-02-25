import Foundation
import UIKit
import Components
import GamebaseFacade

public final class ComponentsProvider: ComponentsProviding {
	// MARK: - Dependencies
	private unowned let application: UIApplication
	private unowned let provider: Providing
	
	// MARK: - ComponentsProviding
	
	// MARK: - Init
	public init(application: UIApplication, provider: Providing) {
		self.application = application
		self.provider = provider
	}
	
	// MARK: - Factory
}
