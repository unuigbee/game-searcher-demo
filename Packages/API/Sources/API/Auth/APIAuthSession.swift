import Foundation
import Combine
import Security

public protocol APIOAuthTokenSession {
	var accountID: String { get }
	var accessToken: String? { get }
	var accessTokenExpirationDate: Date? { get }
	
	func save(_ accessToken: String, accessTokenExpirationTime: Int)
	func accessTokenIsNotExpired() -> Bool
	func clearTokens()
}

public final class SecurePersistedAuthTokenSession: APIOAuthTokenSession {
	public var accessToken: String? {
		get {
			return secureTokenStore.read(clientAccount: accountID, tokenType: .AccessToken)
		}
		set(newValue) {
			if let accessToken = newValue {
				_ = secureTokenStore.save(key: self.accountID, tokenType: .AccessToken, value: accessToken)
			} else {
				_ = secureTokenStore.delete(key: self.accountID, tokenType: .AccessToken)
			}
		}
	}
	
	public var accessTokenExpirationDate: Date? {
		get {
			return Date(secureTokenStore.read(clientAccount: accountID, tokenType: .ExpirationDate))
		}
		set(newValue) {
			if let expirationDate = newValue {
				_ = self.secureTokenStore.save(key: self.accountID, tokenType: .ExpirationDate, value: expirationDate.toString())
			} else {
				_ = self.secureTokenStore.delete(key: self.accountID, tokenType: .ExpirationDate)
			}
		}
	}
	
	private(set) public var accountID: String
	private var tokenCancellable: AnyCancellable?
	private var expirationDateCancellable: AnyCancellable?
	private let secureTokenStore: TokenStore
	
	public init(accountID: String, store: TokenStore = SecureTokenStore()) {
		self.accountID = accountID
		self.secureTokenStore = store
	}
	
	public func save(_ accessToken: String, accessTokenExpirationTime: Int) {
		self.accessToken = accessToken
		let now = Date()
		self.accessTokenExpirationDate = now.addingTimeInterval(TimeInterval(accessTokenExpirationTime))
	}
	
	public func clearTokens() {
		self.accessToken = nil
		self.accessTokenExpirationDate = nil
	}
	
	public func accessTokenIsNotExpired() -> Bool {
		guard let expirationDate = accessTokenExpirationDate, accessToken != nil else {
			return false
		}
		
		return expirationDate.timeIntervalSince(Date()) > 0
	}
}

