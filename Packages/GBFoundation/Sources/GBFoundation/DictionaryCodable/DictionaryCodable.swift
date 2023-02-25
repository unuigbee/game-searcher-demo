import Foundation

public protocol DictionaryDecodable: Decodable {}
public protocol DictionaryEncodable: Encodable {}

public typealias DictionaryCodable = DictionaryDecodable & DictionaryEncodable
