//
//  MockLoader.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


open class MockLoader: HTTPLoader {

    open override func load(_ request: HTTPRequest,
                            completion: @escaping HTTPResultHandler) {

        let error = HTTPError(.cannotConnect, request, nil, "base mock handler")
        completion(.failure(error))

    }

    open override func load(_ request: HTTPRequest) async -> HTTPResult {
        
        let error = HTTPError(.cannotConnect, request, nil, "base mock handler")
        
        return .failure(error)
        
    }
    
}
