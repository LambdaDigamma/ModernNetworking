//
//  HTTPLoader.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation

open class HTTPLoader {

    public var nextLoader: HTTPLoader? {
        willSet {
            guard nextLoader == nil
                else { fatalError("nextLoader may only be set once") }
        }
    }

    public init() {}

    open func load(_ request: HTTPRequest) async -> HTTPResult {
        if let next = nextLoader {
            return await next.load(request)
        } else {
            let error = HTTPError(.cannotConnect, request)
            return .failure(error)
        }
    }

    open func reset() async {
        if let nextLoader {
            await nextLoader.reset()
        }
    }

}
