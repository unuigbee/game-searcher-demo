public typealias OAuthError = AuthenticationAPI.Error

public enum APIError: Error {
	case responseParseError(underlyingError: Error)
	case networkError(underlyingError: Error)
	case authError(underlyingError: OAuthError)
	case httpError(statusCode: Int, errors: ErrorResponse?)
	case cancelled
	case unknownError
	case taskNotAvailable

	public var localizedDescription: String {
		switch self {
		case .cancelled:
			return ""
		case .unknownError:
			return "Unknown error"
		case let .httpError(statusCode, error):
			let message = error?.errors.map { $0.title ?? "" }
				.first(where: { $0.isEmpty == false }) ?? "\(statusCode)"
			return "There was an error reaching the server (\(message))"
		case let .authError(underlyingError):
			return underlyingError.localizedDescription
		case let .networkError(underlyingError):
			return underlyingError.localizedDescription
		case .responseParseError:
			return "There was an error communicating with the server"
		case .taskNotAvailable:
			return "There was an error getting the available task!"
		}
	}
}

public struct ErrorResponse: Decodable {
	public var errors: [LocalError]

	public init(errors: [LocalError]) {
		self.errors = errors
	}
}

public struct LocalError: Decodable {
	public var title: String?
	public var code: String?
	public var detail: String?

	public init(title: String?, code: String?, detail: String?) {
		self.title = title
		self.code = code
		self.detail = detail
	}
}
