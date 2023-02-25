import Foundation

internal struct DictionaryCodingKey: CodingKey {
	public var stringValue: String
	public var intValue: Int?

	public init?(stringValue: String) {
		self.stringValue = stringValue
		intValue = nil
	}

	public init?(intValue: Int) {
		stringValue = "\(intValue)"
		self.intValue = intValue
	}

	public init(stringValue: String, intValue: Int?) {
		self.stringValue = stringValue
		self.intValue = intValue
	}

	internal init(index: Int) {
		stringValue = "Index \(index)"
		intValue = index
	}

	internal static let `super` = DictionaryCodingKey(stringValue: "super")!
}

