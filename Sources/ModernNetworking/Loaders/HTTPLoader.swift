//
//  HTTPLoader.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation
import Dispatch


public typealias HTTPResultHandler = (HTTPResult) -> Void

open class HTTPLoader {

    public var nextLoader: HTTPLoader? {
        willSet {
            guard nextLoader == nil
                else { fatalError("nextLoader may only be set once") }
        }
    }

    public init() {}

    open func load(_ request: HTTPRequest, completion: @escaping HTTPResultHandler) {

        if let next = nextLoader {
            next.load(request, completion: completion)
        } else {
            let error = HTTPError(.cannotConnect, request, nil, "no HTTPLoader available")
            completion(.failure(error))
        }

    }

    open func reset(with group: DispatchGroup) {
        nextLoader?.reset(with: group)
    }

}

extension HTTPLoader {

    public final func reset(
        on queue: DispatchQueue = .main,
        completionHandler: @escaping () -> Void
    ) {
        let group = DispatchGroup()
        self.reset(with: group)
        group.notify(queue: queue, execute: completionHandler)
    }

}

extension String: Error {}
