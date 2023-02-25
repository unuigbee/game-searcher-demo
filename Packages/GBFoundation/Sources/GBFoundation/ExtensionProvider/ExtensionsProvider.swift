import Foundation

/// The purpose of this class is to be extended and constraint it's `BASE` to a specific type.
/// Example
///
///     extension ExtensionsProvider where Base == String { }
public final class ExtensionsProvider<Base> {
	public let base: Base

	fileprivate init(_ base: Base) {
		self.base = base
	}
}

/// Types that use `ExtensionsProvider` to provide extensions should also adopt this protocol in order to have through the `ext` property.
/// Example
///
///     extension ExtensionsProvider where Base == String {
///         func foo() { }
///     }
///     extension String: ExtensionsCompatible { }
///
///     let foo = "text".ext.foo()
public protocol ExtensionsCompatible {
	associatedtype CompatibleType

	var ext: CompatibleType { get }
}

public extension ExtensionsCompatible {
	var ext: ExtensionsProvider<Self> {
		ExtensionsProvider(self)
	}
}
