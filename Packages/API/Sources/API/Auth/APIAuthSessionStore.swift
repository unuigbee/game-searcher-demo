import Foundation
import Security

public protocol TokenStore {
	func save(key: String, tokenType: TokenType, value: String) -> Bool
	func delete(key: String, tokenType: TokenType) -> Bool
	func read(clientAccount: String, tokenType: TokenType) -> String?
	func resetStore() -> Bool
}

public enum TokenType: String {
	case AccessToken
	case ExpirationDate
}

public class SecureTokenStore: TokenStore {
	public var serviceIdentifier: String
	
	public init(serviceID: String? = Bundle.main.bundleIdentifier) {
		if let serviceID = serviceID {
			serviceIdentifier = serviceID
		} else {
			serviceIdentifier = "unknown"
		}
	}
	
	public func save(key: String, tokenType: TokenType, value: String) -> Bool {
		guard let dataFromString = value.data(using: .utf8) else {
			return false
		}
		
		let keyChainQuery = NSMutableDictionary()
		
		keyChainQuery[kSecClass as String] = kSecClassGenericPassword
		keyChainQuery[kSecAttrService as String] = serviceIdentifier
		keyChainQuery[kSecAttrAccount as String] = key + "_" + tokenType.rawValue
		keyChainQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
		
		let statusSearch: OSStatus = SecItemCopyMatching(keyChainQuery, nil)
		
		switch statusSearch {
		case errSecSuccess:
			let attributesToUpdate = NSMutableDictionary()
			attributesToUpdate[kSecValueData as String] = dataFromString
			
			let statusUpdate: OSStatus = SecItemUpdate(keyChainQuery, attributesToUpdate)
			
			if statusUpdate != errSecSuccess {
				return false
			}
		case errSecItemNotFound:
			keyChainQuery[kSecValueData as String] = dataFromString
			let statusAdd: OSStatus = SecItemAdd(keyChainQuery, nil)
			
			if statusAdd != errSecSuccess {
				return false
			}
		default:
			return false
		}
		
		return true
	}
	
	public func read(clientAccount: String, tokenType: TokenType) -> String? {
		let keyChainQuery = NSMutableDictionary()
		
		keyChainQuery[kSecClass as String] = kSecClassGenericPassword
		keyChainQuery[kSecAttrService as String] = serviceIdentifier
		keyChainQuery[kSecAttrAccount as String] = clientAccount + "_" + tokenType.rawValue
		keyChainQuery[kSecMatchLimit as String] = kSecMatchLimitOne
		keyChainQuery[kSecReturnData as String] = kCFBooleanTrue
		keyChainQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
		
		var dataTypeRef: AnyObject?
		let status: OSStatus = withUnsafeMutablePointer(to: &dataTypeRef) {
			SecItemCopyMatching(keyChainQuery as CFDictionary, 	UnsafeMutablePointer($0))
		}
		
		if status == errSecItemNotFound {
			// item not found
			return nil
		} else if status != errSecSuccess {
			// some error
			return nil
		}
		
		guard let keyChainData = dataTypeRef as? Data else {
			return nil
		}
		
		return String(data: keyChainData, encoding: .utf8) as String?
	}
	
	public func delete(key: String, tokenType: TokenType) -> Bool {
		let keyChainQuery = NSMutableDictionary()
		
		keyChainQuery[kSecClass as String] = kSecClassGenericPassword
		keyChainQuery[kSecAttrService as String] = serviceIdentifier
		keyChainQuery[kSecAttrAccount as String] = key + "_" + tokenType.rawValue
		keyChainQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
		
		let statusDelete: OSStatus = SecItemDelete(keyChainQuery)
		
		return statusDelete == noErr
	}
	
	public func resetStore() -> Bool {
		return self.deleteAllKeysForSecClass(secClass: kSecClassGenericPassword) &&
			self.deleteAllKeysForSecClass(secClass: kSecClassInternetPassword) &&
			self.deleteAllKeysForSecClass(secClass: kSecClassCertificate) &&
			self.deleteAllKeysForSecClass(secClass: kSecClassKey) &&
			self.deleteAllKeysForSecClass(secClass: kSecClassIdentity)
	}
	
	private func deleteAllKeysForSecClass(secClass: CFTypeRef) -> Bool {
		let keyChainQuery = NSMutableDictionary()
		keyChainQuery[kSecClass as String] = secClass
		let result: OSStatus = SecItemDelete(keyChainQuery)
		
		return result == errSecSuccess
	}
}
