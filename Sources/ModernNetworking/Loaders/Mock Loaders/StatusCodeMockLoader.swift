//
//  StatusCodeMockLoader.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


/// A mock loader that always creates a successful response with a given status code.
public class StatusCodeMockLoader: MockLoader {

    public let statusCode: HTTPStatusCode

    public init(_ statusCode: HTTPStatusCode) {
        self.statusCode = statusCode
    }

    public override func load(_ request: HTTPRequest,
                              completion: @escaping HTTPResultHandler) {

        let urlResponse = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode.value,
            httpVersion: "1.1",
            headerFields: nil
        )
        
        
        let response = HTTPResponse(request, urlResponse!)
        completion(.success(response))

    }
    
    public override func load(_ request: HTTPRequest) async -> HTTPResult {
        
        let urlResponse = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode.value,
            httpVersion: "1.1",
            headerFields: nil
        )
        
        
        let response = HTTPResponse(request, urlResponse!)
        
        return .success(response)
        
    }
    
}
