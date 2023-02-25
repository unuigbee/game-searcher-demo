import API
import Combine
import Foundation

//public typealias AppCompaniesServiceErrorResponse = RequestErrorResponse<AppCompaniesServiceError>
//
//public enum AppCompaniesServiceError: HashableError {
//	case network(underlyingError: String)
//}
//
//extension AppCompaniesServiceError {
//	init(with error: Error) {
//		self = .network(underlyingError: error.localizedDescription)
//	}
//}
//
//protocol AppCompaniesService {
//	func involvedCompanies(
//		for ids: [Int]
//	) -> AnyPublisher<[AppModels.InvolvedCompany], AppCompaniesServiceErrorResponse>
//	
//	func companies(
//		for ids: [Int]
//	) -> AnyPublisher<[AppModels.Company], AppCompaniesServiceErrorResponse>
//}
//
//public final class DefaultAppCompaniesService<RemoteService: CompanyService>: AppCompaniesService {
//	private let remoteService: RemoteService
//	
//	public init(remoteService: RemoteService) {
//		self.remoteService = remoteService
//	}
//	
//	func companies(for ids: [Int]) -> AnyPublisher<[AppModels.Company], AppCompaniesServiceErrorResponse> {
//		remoteService.companies(for: ids)
//			.map { $0.map(AppModels.Company.init) }
//			.mapError(AppCompaniesServiceError.init)
//			.mapError(AppCompaniesServiceErrorResponse.specific)
//			.eraseToAnyPublisher()
//	}
//	
//	func involvedCompanies(
//		for ids: [Int]
//	) -> AnyPublisher<[AppModels.InvolvedCompany], AppCompaniesServiceErrorResponse> {
//		remoteService.involvedCompanies(for: ids)
//			.map { $0.map(AppModels.InvolvedCompany.init) }
//			.mapError(AppCompaniesServiceError.init)
//			.mapError(AppCompaniesServiceErrorResponse.specific)
//			.eraseToAnyPublisher()
//	}
//}
//
//public struct DefaultGameModel: Hashable {
//	public internal(set) var game: AppModels.Game
//	public internal(set) var involvedCompanies: [AppModels.InvolvedCompany]
//}
//
//extension DefaultGameModel: Identifiable {
//	public var id: Int { game.id }
//}
