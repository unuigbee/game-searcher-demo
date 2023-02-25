import Foundation
import API

// MARK: - RequestError

public enum RequestError<SpecificError: HashableError>: HashableError {
	case responseParseError
	case networkError
	case authError
	case cancelled
	case unknownError
	case specificError(SpecificError)
}

public struct RequestErrorResponse<SpecificError: HashableError>: HashableError {
	public let error: RequestError<SpecificError>
	public let errorDescription: String

	init(
		error: RequestError<SpecificError>,
		errorDescription: String = ""
	) {
		self.error = error
		self.errorDescription = errorDescription
	}
}

public extension RequestErrorResponse {
	static func specific(error: SpecificError) -> Self {
		.init(error: .specificError(error))
	}
}

// MARK: - GenericErrorResponse

public typealias GenericRequestErrorResponse = RequestErrorResponse<NeverError>

extension GenericRequestErrorResponse {
	init(with apiError: APIError) {
		self = .error(fromAPIError: apiError)
	}
}

// MARK: - Helpers

internal extension RequestErrorResponse {
	static func error(fromAPIError apiError: APIError) -> Self {
		switch apiError {
		case let .responseParseError(underlyingError):
			return .init(error: .responseParseError, errorDescription: underlyingError.localizedDescription)
		case let .networkError(underlyingError):
			return .init(error: .networkError, errorDescription: underlyingError.localizedDescription)
		case let .authError(underlyingError):
			return .init(error: .authError, errorDescription: underlyingError.localizedDescription)
		case .httpError:
			return .init(
				error: .networkError,
				errorDescription: """
					 [ErrorResponse misuse]
					 You have attempted to use `.httpError` directly from `APIError`,
					 please decode the expected Error from the API and use the `.specificError` instead
				"""
			)
		case .cancelled:
			return .init(error: .cancelled, errorDescription: "cancelled")
		case .unknownError:
			return .init(error: .unknownError, errorDescription: "unknownError")
		case .taskNotAvailable:
			return .init(error: .unknownError, errorDescription: "")
		}
	}
}
