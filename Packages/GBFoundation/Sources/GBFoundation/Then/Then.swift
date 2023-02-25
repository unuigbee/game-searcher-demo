import Foundation
// Disclaimer: https://github.com/devxoul/Then/blob/master/Sources/Then/Then.swift

public protocol Then {}

extension Then where Self: Any {
	/// Makes it available to set properties with closures just after initializing and copying the value types.
	///
	///     let frame = CGRect().with {
	///       $0.origin.x = 10
	///       $0.size.width = 100
	///     }
	public func with(_ block: (inout Self) throws -> Void) rethrows -> Self {
		var copy = self
		try block(&copy)
		return copy
	}

	/// Makes it available to execute something with closures.
	///
	///     UserDefaults.standard.do {
	///       $0.set("devxoul", forKey: "username")
	///       $0.set("devxoul@gmail.com", forKey: "email")
	///       $0.synchronize()
	///     }
	public func `do`(_ block: (Self) throws -> Void) rethrows {
		try block(self)
	}
}

extension Then where Self: AnyObject {
	/// Makes it available to set properties with closures just after initializing.
	///
	///     let label = UILabel().then {
	///       $0.textAlignment = .Center
	///       $0.textColor = UIColor.blackColor()
	///       $0.text = "Hello, World!"
	///     }
	public func then(_ block: (Self) throws -> Void) rethrows -> Self {
		try block(self)
		return self
	}
}

extension NSObject: Then {}

