import Foundation

public struct EnvironmentConfig {
	public let appEnvironment: AppEnvironment
	
	public init(appEnvironment: AppEnvironment) {
		self.appEnvironment = appEnvironment
	}
}

extension EnvironmentConfig: Decodable {
	private enum CodingKeys: String, CodingKey {
		case appEnvironment = "APP_ENVIRONMENT"
	}
}

public extension EnvironmentConfig {
	enum AppEnvironment: String, Decodable, CaseIterable {
		case development = "DEVELOPMENT"
		case production = "PRODUCTION"
	}
}
