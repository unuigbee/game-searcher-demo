import Foundation

// An Error that can be used as a default in the `.specificError` enum case of `RequestError` when there isn't any.
public typealias HashableError = Error & Hashable
public enum NeverError: HashableError {}
