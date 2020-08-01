//
//  HTTPTask.swift
//  
//
//  Created by Lennart Fischer on 31.07.20.
//

import Foundation


public class HTTPTask {
    
    public var id: UUID { request.id }
    private var request: HTTPRequest
    private let completion: (HTTPResult) -> Void
    
    private var cancellationHandlers = Array<() -> Void>()
    
    public init(request: HTTPRequest, completion: @escaping (HTTPResult) -> Void) {
        self.request = request
        self.completion = completion
    }
    
    public func addCancellationHandler(_ handler: @escaping () -> Void) {
        // TODO: make this thread-safe
        // TODO: what if this was already cancelled?
        // TODO: what if this is already finished but was not cancelled before finishing?
        cancellationHandlers.append(handler)
    }
    
    public func cancel() {
        // TODO: toggle some state to indicate that "isCancelled == true"
        // TODO: make this thread-safe
        let handlers = cancellationHandlers
        cancellationHandlers = []
        
        // invoke each handler in reverse order
        handlers.reversed().forEach { $0() }
    }
    
    public func complete(with result: HTTPResult) {
        completion(result)
    }
    
    public func fail(_ errorCode: HTTPError.Code) {
        completion(.failure(HTTPError(code: errorCode, request: request, response: nil, underlyingError: nil)))
    }
    
}
