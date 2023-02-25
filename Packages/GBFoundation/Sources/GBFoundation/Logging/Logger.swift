import Foundation
import os.log

func log(message: String, appending privateMessage: String? = nil, identifiableByHash: Bool = false) {
	if let privateMessaging = privateMessage {
		if identifiableByHash {
			Logger.api.info("\(message) \(privateMessaging, privacy: .private(mask: .hash))")
		} else {
			Logger.api.info("\(message) \(privateMessaging, privacy: .private(mask: .none))")
		}
	} else {
		Logger.api.info("\(message)")
	}
}

func log(message: String, value: String, isPrivate: Bool = false) {
	if isPrivate {
		Logger.api.info("\(message) \(value, privacy: .private)")
	} else {
		Logger.api.info("\(message) \(value)")
	}
}

extension Logger {
	private static let services = "log.gamebase.services"
	
	static let api = Logger(subsystem: services, category: "api")
}
