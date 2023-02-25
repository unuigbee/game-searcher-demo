import Foundation
import SwiftUI

protocol PreviewConfigurator {
	associatedtype Preview = AnyView
	
	var preview: Self.Preview { get }
	var displayName: String { get }
}

struct PreviewConfiguration<Content: View>: PreviewConfigurator {
	let displayName: String
	let device: String
	let content: Content
	let showsNavigationBar: Bool
	let ignoresEdges: Bool
	
	init(
		displayName: String,
		device: String = PreviewDevice.iPhone12,
		showsNavigationBar: Bool = false,
		ignoresEdges: Bool = false,
		configuration: @escaping () -> Content
	) {
		self.displayName = displayName
		self.device = device
		self.showsNavigationBar = showsNavigationBar
		self.ignoresEdges = ignoresEdges
		self.content = configuration()
	}
	
	var preview: AnyView {
		AnyView(
			NavigationView {
				content
					.edgesIgnoringSafeArea(ignoresEdges ? [.bottom, .top] : [])
					.navigationBarHidden(!showsNavigationBar)
					.navigationBarTitle(
						Text(displayName),
						displayMode: .inline
					)
			}
			.navigationTitle(displayName)
			.previewDevice(.init(rawValue: device))
			.previewDisplayName("\(device) - \(displayName)")
		)
	}
}
