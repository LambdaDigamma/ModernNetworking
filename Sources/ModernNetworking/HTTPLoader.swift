//
//  HTTPLoader.swift
//  24doors
//
//  Created by Lennart Fischer on 17.07.20.
//  Copyright © 2020 LambdaDigamma. All rights reserved.
//

import Foundation
import Combine

precedencegroup LoaderChainingPrecedence {
    higherThan: NilCoalescingPrecedence
    associativity: right
}

infix operator --> : LoaderChainingPrecedence

@available(iOS 13.0, *)
@discardableResult
public func --> (lhs: HTTPLoader?, rhs: HTTPLoader?) -> HTTPLoader? {
    lhs?.nextLoader = rhs
    return lhs ?? rhs
}

@available(iOS 13.0, *)
open class HTTPLoader: HTTPLoading {
    
    public var nextLoader: HTTPLoader? {
        willSet {
            guard nextLoader == nil else { fatalError("The nextLoader may only be set once") }
        }
    }
    
    public init() { }
    
    open func load(request: HTTPRequest, completion: @escaping (HTTPResult) -> Void) {
        
        if let next = nextLoader {
            next.load(request: request, completion: completion)
        } else {
            let error = HTTPError(code: .cannotConnect, request: request, response: nil, underlyingError: nil)
            completion(.failure(error))
        }
        
    }
    
    public func load<T>(request: HTTPRequest) -> AnyPublisher<T, HTTPError> where T : Model {
        
        if let next = nextLoader {
            return next.load(request: request)
        } else {
            let error = HTTPError(code: .cannotConnect, request: request, response: nil, underlyingError: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }
        
    }
    
}
