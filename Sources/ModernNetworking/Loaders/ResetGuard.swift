//
//  File.swift
//  
//
//  Created by Lennart Fischer on 01.08.20.
//

import Foundation

@available(OSX 10.15, *)
@available(iOS 13.0, *)
public class ResetGuard: HTTPLoader {

    private var isResetting = false
    private let lock = NSLock()
//    private let queue = DispatchQueue(label: "ResetGuard")
    
    public override func load(request: HTTPRequest, completion: @escaping (HTTPResult) -> Void) {
        
        // TODO: make this thread-safe
        
        lock.lock()
        
        if isResetting == false {
            super.load(request: request, completion: completion)
        } else {
            let error = HTTPError(code: .resetInProgress, request: request, response: nil, underlyingError: nil)
            completion(.failure(error))
        }
        
        lock.unlock()
        
    }
    
    public override func reset(with group: DispatchGroup) {
        
        lock.lock()
        // TODO: make this thread-safe
        if isResetting == true { return }
        guard let next = nextLoader else { return }
        lock.unlock()
        
        group.enter()
        isResetting = true
        next.reset {
            self.isResetting = false
            group.leave()
        }
        
    }
    
}
