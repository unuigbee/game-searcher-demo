import Foundation

public actor APITaskManager: APITaskDelegate {
	private let requester: APIDataRequester
	private let authenticator: APIAuthenticator
	private let clientId: String
	private let encoder: JSONEncoder = {
		let encoder = JSONEncoder()
		encoder.keyEncodingStrategy = .convertToSnakeCase
		return encoder
	}()
	private let decoder: JSONDecoder = {
		let decoder = JSONDecoder()
		return decoder
	}()
	
	private var activeTasks: [AnyHashable: Any] = [:]
	
	public init(
		clientId: String,
		requester: APIDataRequester,
		authenticator: APIAuthenticator
	) {
		self.clientId = clientId
		self.requester = requester
		self.authenticator = authenticator
	}
	
	public func task<Response: Decodable>(
		for url: URL,
		query: some APIQuery
	) async throws -> APITask<Response> {
		let taskIdentifier = "\(url.absoluteString)-\(query.id)"
		
		if let existingTask = activeTasks[taskIdentifier] as? APITask<Response>,
		   await [.ready, .running].contains(existingTask.state) {
			print("### reusing task")
			return existingTask
		}
		
		let urlRequest = try await makeURLRequest(for: url, query: query)
		
		let task = APITask<Response>(
			id: taskIdentifier,
			request: urlRequest,
			session: requester,
			decoder: decoder,
			delegate: self
		)
		
		activeTasks[taskIdentifier] = task
		
		await task.start()
	
		return task
	}
	
	public func execute<Response: Decodable>(
		for url: URL,
		query: some APIQuery
	) async throws -> Response {
		try await task(for: url, query: query).value as Response
	}
	
	private func makeURLRequest(
		for url: URL,
		query: some APIQuery
	) async throws -> URLRequest {
		var urlRequest = URLRequest(
			url: url,
			httpMethod: "POST",
			httpBody: query.body()
		)
		
		let authToken = try await authenticator.getToken()
		
		urlRequest.client(clientId)
		urlRequest.bearer(authToken)
		urlRequest.accept("application/json")
		
		return urlRequest
	}
	
	func didCompleteTask(for id: String) async {
		activeTasks[id] = nil
	}
}
