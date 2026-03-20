//
//  DataMockLoader.swift
//  
//
//  Created by Lennart Fischer on 10.01.21.
//

import Foundation


/// A mock loader that always creates a successful response with a
/// given status code and your provided data.
public class DataMockLoader: MockLoader {
    
    public let statusCode: HTTPStatusCode
    public let headers: [String: String]
    public var data: Data? = nil
    
    public init(
        returnedData data: Data?,
        _ statusCode: HTTPStatusCode = .ok,
        headers: [String: String] = [:]
    ) {
        
        self.statusCode = statusCode
        self.headers = headers
        self.data = data
        
    }
    
    public convenience init(
        dataString: String?,
        _ statusCode: HTTPStatusCode = .ok,
        headers: [String: String] = [:],
        encoding: String.Encoding = .utf8
    ) {
        
        let data = dataString?.data(using: encoding)
        
        self.init(returnedData: data, statusCode, headers: headers)
        
    }
    
    public override func load(_ request: HTTPRequest) async -> HTTPResult {
        guard let url = request.url else {
            return .failure(HTTPError(.invalidRequest(.invalidURL), request))
        }

        guard let urlResponse = HTTPURLResponse(
            url: url,
            statusCode: statusCode.value,
            httpVersion: "1.1",
            headerFields: headers
        ) else {
            return .failure(HTTPError(.invalidResponse, request))
        }

        return .success(HTTPResponse(request, urlResponse, data))
    }
    
}
