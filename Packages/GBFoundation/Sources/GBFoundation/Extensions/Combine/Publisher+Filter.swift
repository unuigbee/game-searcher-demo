import Combine

public extension Publisher {
	func filter<A: AnyObject>(weak obj: A, selector: @escaping (A, Output) -> Bool) -> Publishers.Filter<Self> {
		filter { [weak obj] value -> Bool in
			guard let obj = obj else {
				return false
			}
			return selector(obj, value)
		}
	}
}
