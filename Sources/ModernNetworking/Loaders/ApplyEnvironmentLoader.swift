//
//  ApplyEnvironmentLoader.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


public class ApplyEnvironmentLoader: HTTPLoader {

    public init(environment: ServerEnvironment) {
        self.environment = environment
        super.init()
    }

    private let environment: ServerEnvironment

    override public func load(_ request: HTTPRequest) async -> HTTPResult {
        let copy = applyEnvironment(to: request)
        return await super.load(copy)
    }

    private func applyEnvironment(to request: HTTPRequest) -> HTTPRequest {
        var copy = request

        let requestEnvironment = request.serverEnvironment ?? environment

        copy.scheme = requestEnvironment.scheme
        
        if copy.host?.isEmpty ?? true {
            copy.host = requestEnvironment.host
        }

        if copy.path.hasPrefix("/") == false {
            // TODO: apply the environment.pathPrefix | is this done?
            copy.path = requestEnvironment.pathPrefix + "/" + copy.path
        }
        
        // TODO: apply the query items from requestEnvironment | is this right?
        copy.queryItems.append(contentsOf: requestEnvironment.query)
        
        for (header, value) in requestEnvironment.headers {
            copy.headers.updateValue(value, forKey: header)
        }

        return copy
    }
}
