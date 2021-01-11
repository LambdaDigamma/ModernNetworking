//
//  DataMockLoader.swift
//  
//
//  Created by Lennart Fischer on 10.01.21.
//

import Foundation
import Combine


/// A mock loader that always creates a successful response with a
/// given status code and your provided data.
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
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
    
    public override func load(
        _ request: HTTPRequest,
        completion: @escaping HTTPResultHandler
    ) {
        
        let urlResponse = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode.value,
            httpVersion: "1.1",
            headerFields: headers
        )
        
        let response = HTTPResponse(request, urlResponse!, data)
        completion(.success(response))
        
    }
    
}

