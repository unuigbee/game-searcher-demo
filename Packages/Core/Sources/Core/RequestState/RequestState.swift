import Foundation

public enum RequestState<SpecificError: HashableError>: Hashable {
	case loading
	case error(RequestErrorResponse<SpecificError>)
	case success
}

public extension RequestState {
	var requestError: RequestErrorResponse<SpecificError>? {
		switch self {
		case let .error(requestError):
			return requestError
		default:
			return nil
		}
	}
}

// MARK: - Generic

public typealias GenericRequestState = RequestState<NeverError>
