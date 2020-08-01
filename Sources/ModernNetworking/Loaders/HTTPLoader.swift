//
//  HTTPLoader.swift
//  24doors
//
//  Created by Lennart Fischer on 17.07.20.
//  Copyright © 2020 LambdaDigamma. All rights reserved.
//

import Foundation
import Combine

@available(OSX 10.15, *)
@available(iOS 13.0, *)
open class HTTPLoader {
    
    public var nextLoader: HTTPLoader? {
        willSet {
            guard nextLoader == nil else { fatalError("The nextLoader may only be set once") }
        }
    }
    
    public init() { }
    
//    open func load(task: HTTPTask) {
//        if let next = nextLoader {
//            next.load(task: task)
//        } else {
//            // a convenience method to construct an HTTPError
//            // and then call .complete with the error in an HTTPResult
//            task.fail(.cannotConnect)
//        }
//    }
    
    open func load(request: HTTPRequest, completion: @escaping (HTTPResult) -> Void) {

        if let next = nextLoader {
            next.load(request: request, completion: completion)
        } else {
            let error = HTTPError(code: .cannotConnect, request: request, response: nil, underlyingError: nil)
            completion(.failure(error))
        }

    }
    
    open func reset(with group: DispatchGroup) {
        nextLoader?.reset(with: group)
    }
    
}


@available(OSX 10.15, *)
@available(iOS 13.0, *)
extension HTTPLoader {
    
//    public func load(request: HTTPRequest, completion: @escaping (HTTPResult) -> Void) -> HTTPTask {
//        let task = HTTPTask(request: request, completion: completion)
//        load(task: task)
//        return task
//    }
    
    public final func reset(on queue: DispatchQueue = .main, completionHandler: @escaping () -> Void) {
        let group = DispatchGroup()
        self.reset(with: group)
        
        group.notify(queue: queue, execute: completionHandler)
    }

    
}



//@available(OSX 10.15, *)
//@available(iOS 13.0, *)
//open class HTTPLoader {
//
//    public var nextLoader: HTTPLoader? {
//        willSet {
//            guard nextLoader == nil else { fatalError("The nextLoader may only be set once") }
//        }
//    }
//
//    public init() { }
//
//    open func load(request: HTTPRequest, completion: @escaping (HTTPResult) -> Void) {
//
//        if let next = nextLoader {
//            next.load(request: request, completion: completion)
//        } else {
//            let error = HTTPError(code: .cannotConnect, request: request, response: nil, underlyingError: nil)
//            completion(.failure(error))
//        }
//
//    }
//
//    open func reset(with group: DispatchGroup)
//
//    open func load<T>(request: HTTPRequest) -> AnyPublisher<T, HTTPError> where T : Model {
//
//        if let next = nextLoader {
//            return next.load(request: request)
//        } else {
//            let error = HTTPError(code: .cannotConnect, request: request, response: nil, underlyingError: nil)
//            return Fail(error: error).eraseToAnyPublisher()
//        }
//
//    }
//
//}
