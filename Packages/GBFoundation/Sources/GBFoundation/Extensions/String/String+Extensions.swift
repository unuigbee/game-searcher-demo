import Foundation

public extension Optional where Wrapped == String {
	var isNilOrEmpty: Bool {
		self?.isEmpty ?? true
	}

	func contains(_ text: String?) -> Bool {
		self?.contains(text) ?? false
	}
}

public extension String {
	func capitalizingFirstLetter() -> String {
		return prefix(1).capitalized + dropFirst()
	}

	mutating func capitalizeFirstLetter() {
		self = self.capitalizingFirstLetter()
	}
	
	var isEmail: Bool {
		let regex = "[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}\\@"
			+ "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+"
		return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
	}
	
	func camelCased() -> String {
		components(separatedBy: .whitespaces)
			.map { $0.lowercased() }
			.enumerated()
			.map { $0 != 0 ? $1.capitalized : $1 }
			.joined()
	}
	
	func contains(_ text: String?, ignoringCase: Bool = true) -> Bool {
		guard let text = text else { return false }
		return ignoringCase ? lowercased().contains(text.lowercased()) : contains(text)
	}
	
	func removingWhitespace() -> String {
		components(separatedBy: .whitespacesAndNewlines).joined()
	}

	func trimmingWhitespace() -> String {
		trimmingCharacters(in: .whitespacesAndNewlines)
	}
}
