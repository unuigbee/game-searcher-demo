import Foundation
import os.log

public extension URLRequest {
	init(url: URL, httpMethod: String, httpBody: Data?) {
		self.init(url: url)
		self.httpMethod = httpMethod
		self.httpBody = httpBody
	}
	
	func cURL(pretty: Bool = false) -> String {
		let newLine = pretty ? "\\\n" : ""
		let method = (pretty ? "--request " : "-X ") + "\(self.httpMethod ?? "GET") \(newLine)"
		let url: String = (pretty ? "--url " : "") + "\'\(self.url?.absoluteString ?? "")\' \(newLine)"
		
		var cURL = "curl "
		var header = ""
		var data: String = ""
		
		if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
			for (key,value) in httpHeaders {
				header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
			}
		}
		
		if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8),  !bodyString.isEmpty {
			data = "--data '\(bodyString)'"
		}
		
		cURL += method + url + header + data
		
		return cURL
	}
	
	mutating func bearer(_ value: String) {
		setValue("Bearer \(value)", forHTTPHeaderField: "Authorization")
	}
	
	mutating func client(_ value: String) {
		setValue(value, forHTTPHeaderField: "Client-ID")
	}
	
	mutating func accept(_ value: String) {
		setValue(value, forHTTPHeaderField: "Accept")
	}
}
