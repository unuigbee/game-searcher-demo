import Foundation
import UIKit

public protocol ImageURLFormatting {
	func formattedImageURL(url: String, for size: ImageURLFormatter.Size) -> URL?
}

public extension ImageURLFormatting {
	static func formattedImageURL(url: String, for size: ImageURLFormatter.Size) -> URL? {
		return URL(string: "https:" + size.url(url))
	}
}

public final class ImageURLFormatter: ImageURLFormatting {
	public init() { }
	
	public func formattedImageURL(url: String, for size: Size) -> URL? {
		return URL(string: "https:" + size.url(url))
	}
}

extension ImageURLFormatter {
	public enum Size: String, CaseIterable {
		case micro = "t_micro"
		case coverSmall = "t_cover_small"
		case coverBig = "t_cover_big"
		case thumb = "t_thumb"
		case logoMed = "t_logo_med"
		case screenShotMedium = "t_screenshot_med"
		case screenShotBig = "t_screenshot_big"
		case screenShotHuge = "t_screenshot_huge"
		
		public var retina: String {
			return self.rawValue + "_2x"
		}
		
		public var dimension: CGSize {
			switch self {
			case .micro:
				return .init(width: 35, height: 35)
			case .thumb:
				return .init(width: 90, height: 90)
			case .coverSmall:
				return .init(width: 90, height: 128)
			case .coverBig:
				return .init(width: 264, height: 374)
			case .logoMed:
				return .init(width: 284, height: 160)
			case .screenShotMedium:
				return .init(width: 569, height: 320)
			case .screenShotBig:
				return .init(width: 889, height: 500)
			case .screenShotHuge:
				return .init(width: 1280, height: 720)
			}
		}
		
		func url(_ url: String) -> String {
			var formattedURL: String? = nil
			
			ImageURLFormatter.Size.allCases.forEach { sizes in
				if url.contains(sizes.rawValue) {
					formattedURL = url.replacingOccurrences(of: sizes.rawValue, with: retina)
				}
			}
			
			return formattedURL ?? url
		}
	}
}
