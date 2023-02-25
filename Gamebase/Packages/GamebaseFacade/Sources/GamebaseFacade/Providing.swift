import Foundation

public protocol AnyProvider {
	var provider: any Providing { get }
}

public protocol Providing: AnyObject {
	var core: any CoreProviding { get }
	var features: any FeaturesProviding { get }
	var storage: any StorageProviding { get }
	var config: any ConfigService { get }
}
