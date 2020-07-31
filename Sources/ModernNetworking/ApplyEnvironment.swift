//
//  ApplyEnvironment.swift
//  24doors
//
//  Created by Lennart Fischer on 18.07.20.
//  Copyright © 2020 LambdaDigamma. All rights reserved.
//

import Foundation


@available(iOS 13.0, *)
public class ApplyEnvironment: HTTPLoader {
    
    private let environment: ServerEnvironment
    
    public init(environment: ServerEnvironment) {
        self.environment = environment
        super.init()
    }
    
    override public func load(request: HTTPRequest, completion: @escaping (HTTPResult) -> Void) {
        var copy = request

        // use the environment specified by the request, if it's present
        // if it doesn't have one, use the one passed to the initializer
        let requestEnvironment = request.serverEnvironment ?? environment

        
        if (copy.host ?? "").isEmpty {
            copy.host = requestEnvironment.host
        }
        if copy.path.hasPrefix("/") == false {
            
            // TODO: apply the environment.pathPrefix | is this done?
            copy.path = requestEnvironment.pathPrefix + copy.path
            
        }
        // TODO: apply the query items from the environment
        for (header, value) in requestEnvironment.headers {
            copy.headers.updateValue(value, forKey: header)
        }
        
        super.load(request: copy, completion: completion)
    }
}
