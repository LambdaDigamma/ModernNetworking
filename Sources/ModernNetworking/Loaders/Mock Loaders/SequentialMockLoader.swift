//
//  SequentialMockLoader.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


public typealias AsyncMockHandler = (HTTPRequest) async -> HTTPResult

public class SequentialMockLoader: MockLoader {

    private var nextHandlers = Array<AsyncMockHandler>()
    
    public override func load(_ request: HTTPRequest) async -> HTTPResult {
        if nextHandlers.isEmpty == false {
            let next = nextHandlers.removeFirst()
            return await next(request)
        } else {
            return .failure(HTTPError(.cannotConnect, request))
        }
    }
    
    @discardableResult
    public func then(_ handler: @escaping AsyncMockHandler) -> MockLoader {
        nextHandlers.append(handler)
        return self
    }
    
}
