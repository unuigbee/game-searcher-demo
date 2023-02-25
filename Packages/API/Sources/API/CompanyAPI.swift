import Foundation
import Combine

public protocol CompanyService {
	func involvedCompanies(for ids: [Int]) -> AnyPublisher<[InvolvedCompany], Error>
}

public final class CompanyAPI: CompanyService {
	private let network: NetworkDataPublisher
	private let endpoints: API.Endpoints
	
	private var decoder: JSONDecoder = {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}()
	
	public init(network: NetworkDataPublisher = Network(), endpoints: API.Endpoints) {
		self.network = network
		self.endpoints = endpoints
	}
	
	public func involvedCompanies(for ids: [Int]) -> AnyPublisher<[InvolvedCompany], Error> {
		guard ids.isEmpty == false else {
			return .just([])
		}
		
		let url = URL(string: endpoints.involvedCompanies)!
	
		let condition = API.Clause.Components(property: "id", postFix: .equalTo, value: ids)
		let filter = API.Clause.where(condition)
		
		let query: API.Query = API.Query(
			fields: AssociatedCompaniesFields.self,
			filters: [filter]
		)
		
		let publisher = network
			.publisher(for: url, with: query)
			.decode(type: [InvolvedCompany].self, decoder: decoder)
			.eraseToAnyPublisher()
		
		return publisher
	}
	
	private enum CompanyFields: String, CaseIterable, APIQueryField {
		case name
		case description
		case developed
		case logo
		
		static var all: String {
			CompanyFields
				.allCases
				.map({ $0.rawValue })
				.joined(separator: ",")
		}
	}
	
	private enum AssociatedCompaniesFields: String, CaseIterable, APIQueryField {
		case company
		case game
		case publisher
		case developer
		
		static var all: String {
			AssociatedCompaniesFields
				.allCases
				.map({ $0.rawValue })
				.joined(separator: ",")
		}
	}

}

