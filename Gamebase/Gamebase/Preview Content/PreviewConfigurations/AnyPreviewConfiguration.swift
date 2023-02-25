//
//  AnyPreviewConfiguration.swift
//  Gamebase
//
//  Created by Emmanuel Unuigbe on 09/06/2021.
//

import SwiftUI

struct AnyPreviewConfiguration<Preview>: PreviewConfigurator, Identifiable {
	let id: UUID = UUID()
	
	private let _preview: () -> Preview
	private let _displayName: () -> String
	
	init<Configurator: PreviewConfigurator>(_ configuration: Configurator)
	where Configurator.Preview == Preview {
		_preview = { configuration.preview }
		_displayName = { configuration.displayName }
	}
	
	var preview: Preview {
		return _preview()
	}
	
	var displayName: String {
		_displayName()
	}
}

private extension PreviewConfigurator {
	var eraseToAnyConfiguration: AnyPreviewConfiguration<Preview> {
		AnyPreviewConfiguration(self)
	}
}

extension Collection where Element: PreviewConfigurator {
	var eraseToAnyConfigurations: [AnyPreviewConfiguration<Element.Preview>] {
		map { $0.eraseToAnyConfiguration }
	}
}
