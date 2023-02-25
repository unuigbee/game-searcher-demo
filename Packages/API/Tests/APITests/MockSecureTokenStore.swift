//
//  MockSecureTokenStore.swift
//  
//
//  Created by Emmanuel Unuigbe on 21/08/2021.
//

import Foundation
import Utility

public class MockTokenStore: TokenStore {
	public var token: String?
	public var expirationDate: String?
	
	public var stubSaveMethodWasCalled = false
	public var stubDeleteMethodWasCalled = false
	public var stubReadMethodWasCalled = false
	public var stubResetStoreMethodWasCalled = false
	
	public init() {}
	
	public func save(key: String, tokenType: TokenType, value: String) -> Bool {
		stubSaveMethodWasCalled = true
		
		switch tokenType {
		case .AccessToken:
			token = value
		case .ExpirationDate:
			expirationDate = value
		}
		
		return true
	}
	
	public func delete(key: String, tokenType: TokenType) -> Bool {
		stubDeleteMethodWasCalled = true
		
		switch tokenType {
		case .AccessToken:
			token = nil
		case .ExpirationDate:
			expirationDate = nil
		}
		
		return true
	}
	
	public func read(clientAccount: String, tokenType: TokenType) -> String? {
		stubReadMethodWasCalled = true
		
		switch tokenType {
		case .AccessToken:
			return token
		case .ExpirationDate:
			return expirationDate
		}
	}
	
	public func resetStore() -> Bool {
		stubResetStoreMethodWasCalled = true
		
		token = nil
		expirationDate = nil
		
		return true
	}
}

public class MockAuthTokenSession: APIOAuthTokenSession {
	public let accountID: String
	public var accessToken: String?
	public var accessTokenExpirationDate: Date?
	public var isTokenExpired: Bool = true
	
	public var stubClearTokensMethodIsCalled = false
	public var stubSaveTokenMethodIsCalled = false
	public var stubAccessTokenIsNotExpiredMethodIsCalled = false
	
	public init(accountID: String = "testAccountID") {
		self.accountID = accountID
	}
	
	public func save(_ accessToken: String, accessTokenExpirationTime: Int) {
		stubSaveTokenMethodIsCalled = true
	}
	
	public func accessTokenIsNotExpired() -> Bool {
		stubAccessTokenIsNotExpiredMethodIsCalled = true
		return !isTokenExpired
	}
	
	public func clearTokens() {
		stubClearTokensMethodIsCalled = true
	}
}
