//
//  SequentialMockLoader.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


public typealias HTTPHandler = (HTTPResult) -> Void
public typealias MockHandler = (HTTPRequest, HTTPHandler) -> Void

public class SequentialMockLoader: MockLoader {

    private var nextHandlers = Array<MockHandler>()
    
    public override func load(_ request: HTTPRequest, completion: @escaping HTTPHandler) {
        if nextHandlers.isEmpty == false {
            let next = nextHandlers.removeFirst()
            next(request, completion)
        } else {
            let error = HTTPError(.cannotConnect, request, nil, "base mock handler")
            completion(.failure(error))
        }
    }
    
    @discardableResult
    public func then(_ handler: @escaping MockHandler) -> MockLoader {
        nextHandlers.append(handler)
        return self
    }
    
}
