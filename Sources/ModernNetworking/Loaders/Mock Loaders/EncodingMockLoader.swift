//
//  EncodingMockLoader.swift
//  
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation
import Combine


/// A mock loader that always creates a successful response with a
/// given status code and your provided codable data.
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public class EncodingMockLoader: MockLoader {
    
    public let statusCode: HTTPStatusCode
    public let headers: [String: String]
    public var data: Data? = nil
    
    
    public init<EncodingType: Encodable, Encoder: TopLevelEncoder>(
        returnedData data: EncodingType,
        _ statusCode: HTTPStatusCode = .ok,
        encoder: Encoder,
        headers: [String: String] = [:]
    ) where Encoder.Output == Data {
        
        self.statusCode = statusCode
        self.headers = headers
        
        do {
            self.data = try encoder.encode(data)
        } catch {
            print("Some error occured while encoding:")
            print(error.localizedDescription)
        }
        
    }
    
    public convenience init<M: Model>(model: M,
                                      _ statusCode: HTTPStatusCode = .ok,
                                      headers: [String: String] = [:]) {
        self.init(returnedData: model, statusCode, encoder: M.encoder, headers: headers)
    }
    
    public override func load(_ request: HTTPRequest,
                              completion: @escaping HTTPResultHandler) {
        
        let urlResponse = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode.value,
            httpVersion: "1.1",
            headerFields: headers
        )
        
        let response = HTTPResponse(request, urlResponse!, data)
        completion(.success(response))
        
    }
    
    public override func load(_ request: HTTPRequest) async -> HTTPResult {
    
        let urlResponse = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode.value,
            httpVersion: "1.1",
            headerFields: headers
        )
        
        let response = HTTPResponse(request, urlResponse!, data)
        
        return .success(response)
        
    }
    
}
