import Foundation

public protocol ConfigService {
	var appConfig: AppConfig { get }
}

public enum ConfigServiceError: Error {
	case pathNotFound(String)
	case dataInvalid
}
