import Foundation

public protocol APIDataRequester {
	func data(
		for request: URLRequest,
		delegate: URLSessionTaskDelegate?
	) async throws -> (Data, URLResponse)
}

extension URLSession: APIDataRequester {}

protocol APITaskDelegate: AnyObject {
	func didCompleteTask(for id: String) async
}

public actor APITask<T: Decodable> {
	private let id: String
	private let request: URLRequest
	private let session: APIDataRequester
	private let decoder: JSONDecoder
	
	private var task: Task<T, Error>?
	private weak var delegate: APITaskDelegate?
	private(set) var state: State = .ready
	
	init(
		id: String,
		request: URLRequest,
		session: APIDataRequester,
		decoder: JSONDecoder,
		delegate: APITaskDelegate? = nil
	) {
		self.id = id
		self.request = request
		self.session = session
		self.decoder = decoder
		self.delegate = delegate
	}
	
	// MARK: Public
	
	public var value: T {
		get async throws {
			guard let result = try await task?.value else {
				throw APIError.taskNotAvailable
			}
		
			return result
		}
	}
	
	public func start() async {
		let noTask = task == nil
		let manuallyCancelled = state == .cancelled
		let networkFailed = await checkNetworkFailed()
		
		guard noTask || manuallyCancelled || networkFailed else {
			return
		}
		
		state = .running
		
		createTask()
	}
	
	public func cancel() {
		guard state == .running else {
			return
		}
		
		task?.cancel()
		
		state = .cancelled
	}
	
	// MARK: Private
	
	private func createTask() {
		let task = Task {
			do {
				print("Starting network request...")
				let (data, response) = try await session.data(for: request, delegate: nil)
				
				try handleResponse(response: response)
				
				print("Processing data from task...")
				let decoded = try decoder.decode(T.self, from: data)
				
				try Task.checkCancellation()
				
				print("Task complete...")
				state = .complete
				
				await delegate?.didCompleteTask(for: id)
				
				return decoded
			} catch {
				print("Task error: \(error) caught...")
				throw mapError(error: error)
			}
		}
		
		self.task = task
	}
	
	private func handleResponse(response: URLResponse) throws {
		guard let response = response as? HTTPURLResponse else {
			return
		}
		
		guard (200..<300).contains(response.statusCode) == false else {
			return
		}
		
		throw APIError.httpError(statusCode: response.statusCode, errors: nil)
	}
	
	private func mapError(error: Error) -> APIError {
		if error is DecodingError {
			state = .error
			return APIError.responseParseError(underlyingError: error)
		}
		
		if error is CancellationError {
			state = .cancelled
			return APIError.cancelled
		}
		
		guard (error as NSError).code != NSURLErrorCancelled else {
			state = .cancelled
			return APIError.cancelled
		}
		
		state = .error
		return APIError.networkError(underlyingError: error)
	}
	
	private func checkNetworkFailed() async -> Bool {
		guard let result = await task?.result else {
			return false
		}
		
		guard case .failure(let error) = result else {
			return false
		}

		let networkFailed = [
			NSURLErrorCancelled,
			NSURLErrorNotConnectedToInternet,
			Int(ECONNABORTED),
			NSURLErrorNetworkConnectionLost
		]
		.contains((error as NSError?)?.code)
		
		return networkFailed
	}
}

extension APITask {
	enum State: Hashable {
		case ready
		case running
		case complete
		case error
		case cancelled
	}
}
