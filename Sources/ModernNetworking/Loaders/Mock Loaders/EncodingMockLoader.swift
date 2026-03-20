//
//  EncodingMockLoader.swift
//  
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


/// A mock loader that always creates a successful response with a
/// given status code and your provided codable data.
public class EncodingMockLoader: MockLoader {
    
    public let statusCode: HTTPStatusCode
    public let headers: [String: String]
    public var data: Data? = nil
    
    
    public init<EncodingType: Encodable>(
        returnedData data: EncodingType,
        _ statusCode: HTTPStatusCode = .ok,
        encoder: JSONEncoder = JSONEncoder(),
        headers: [String: String] = [:]
    ) {
        
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
