import Foundation
import GBFoundation

public protocol APIQueryField: RawRepresentable, CaseIterable {
	static var all: String { get }
}

extension APIQueryField {
	static var all: String {
		Self.allCases
			.map(\.rawValue)
			.map(String.init(describing:))
			.joined(separator: ",")
	}
}

public protocol APIQueryClause {
	var clause: String { get }
}

public protocol APIQuery: Identifiable {
	var id: String { get }
	func body() -> Data?
}

public protocol APIQueryCondition {
	var condition: String? { get }
}

public protocol APISearchQuery {
	var query: String { get }
}

public protocol APIPaginatedQuery {
	var offset: Int { get }
	var limit: Int { get }
	
	var query: String { get }
}

public protocol APIClauseComponent {
	associatedtype Value
	
	var property: String { get }
	var postFix: API.Clause.PostFix { get }
	var value: Value { get }
}

public struct API {}

// MARK: - Query Body

public extension API {
	struct Query: APIQuery {
		private let fields: any APIQueryField.Type
		private let filters: [APIQueryClause]?
		private let search: APISearchQuery?
		private let pagination: APIPaginatedQuery?
		
		public var id: String {
			let searchQuery = search(search)
			let fieldsQuery = fields(fields)
			let filtersQuery = filters(filters)
			let paginationQuery = paginate(pagination)
			
			let queries = [
				searchQuery.nilIfEmpty,
				fieldsQuery.nilIfEmpty,
				filtersQuery.nilIfEmpty,
				paginationQuery.nilIfEmpty
			]
			.compactMap(\.value)
			.joined()
			
			return queries
		}
		
		public init(
			fields: any APIQueryField.Type,
			filters: [APIQueryClause]? = nil,
			search: APISearchQuery? = nil,
			pagination: APIPaginatedQuery? = nil
		) {
			self.fields = fields
			self.filters = filters
			self.search = search
			self.pagination = pagination
		}
		
		public func body() -> Data? {
			let query = search(search) + fields(fields) + filters(self.filters) + paginate(self.pagination)
			print("### query: \(query)")
			return query.data(using: .utf8)
		}
		
		private func fields(_ fields: any APIQueryField.Type) -> String {
			return "fields \(fields.all);"
		}
		
		private func filters(_ filters: [APIQueryClause]?) -> String {
			guard let filter = filters else { return "" }
			
			return filter
				.map { "\($0.clause)" }
				.joined(separator: " ")
		}
		
		private func search(_ search: APISearchQuery?) -> String {
			guard let search, !search.query.isEmpty else { return "" }
			return search.query
		}
		
		private func paginate(_ pagination: APIPaginatedQuery?) ->  String {
			guard let pagination else { return "" }
			return pagination.query
		}
	}
}

// MARK: - Query Condition

public extension API {
	enum Clause: APIQueryClause {
		case `where`(APIQueryCondition)
		case exclude
		
		public var clause: String {
			switch self {
			case .where(let component):
				guard let condition = component.condition else {
					break
				}
				return "where \(condition);"
			case .exclude:
				return "exclude"
			}
			return ""
		}
		
		public enum PostFix {
			case equalTo
			case greaterThan
			case lessThan
			case greaterThanOrEqualTo
			
			public var symbol: String {
				switch self {
				case .equalTo:
					return "="
				case .greaterThan:
					return ">"
				case .lessThan:
					return "<"
				case .greaterThanOrEqualTo:
					return ">="
				}
			}
		}
		
		public struct Components<T>: APIClauseComponent, APIQueryCondition {
			public let property: String
			public let postFix: PostFix
			public let value: T
			
			public init(
				property: String,
				postFix: PostFix,
				value: T
			) where T == Array<LosslessStringConvertible> {
				self.property = property
				self.postFix = postFix
				self.value = value
			}
			
			public init(
				property: String,
				postFix: PostFix,
				value: T
			) where T: LosslessStringConvertible {
				self.property = property
				self.postFix = postFix
				self.value = value
			}
			
			public var condition: String? {
				switch value {
				case let value as Array<LosslessStringConvertible>:
					let matchedValues = value
						.map { "\($0)" }
						.joined(separator: ",")
					
					return "\(property) \(postFix.symbol) (\(matchedValues))"
				case let value as LosslessStringConvertible:
					return "\(property) \(postFix.symbol) \(value)"
				default: break
				}
				
				return nil
			}
		}
	}
}

public extension API {
	struct Paginated: APIPaginatedQuery {
		public var offset: Int
		public var limit: Int
		
		public init(offset: Int, limit: Int) {
			self.offset = offset
			self.limit = limit
		}
		
		public var query: String {
			let limit = "limit \(limit);"
			let offset = "offset \(offset);"
			
			return limit + offset
		}
	}
	
	struct Search: APISearchQuery {
		private let searchString: String
		
		public init(_ searchString: String) {
			self.searchString = searchString
		}
		
		public var query: String {
			let escapedSearchString = "\"\(searchString)\""
			
			return "search \(escapedSearchString);"
		}
	}
}

extension API.Clause {
	static func condition<T: LosslessStringConvertible>(
		matching id: T
	) -> some APIQueryCondition {
		Components(property: "id", postFix: .equalTo, value: id)
	}
	
	static func condition<T>(
		matching ids: Array<T>
	) -> some APIQueryCondition where T: LosslessStringConvertible {
		Components(property: "id", postFix: .equalTo, value: ids)
	}
}
