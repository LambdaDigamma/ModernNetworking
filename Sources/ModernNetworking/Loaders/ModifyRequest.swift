//
//  ModifyRequest.swift
//  24doors
//
//  Created by Lennart Fischer on 17.07.20.
//  Copyright © 2020 LambdaDigamma. All rights reserved.
//

import Foundation
import Combine

@available(OSX 10.15, *)
@available(iOS 13.0, *)
public class ModifyRequest: HTTPLoader {
    
    private let modifier: (HTTPRequest) -> HTTPRequest
    
    public init(modifier: @escaping (HTTPRequest) -> HTTPRequest) {
        self.modifier = modifier
        super.init()
    }
    
    override public func load(request: HTTPRequest, completion: @escaping (HTTPResult) -> Void) {
        let modifiedRequest = modifier(request)
        super.load(request: modifiedRequest, completion: completion)
    }
    
//    public override func load<T>(request: HTTPRequest) -> AnyPublisher<T, HTTPError> where T : Model {
//        let modifiedRequest = modifier(request)
//        return super.load(request: modifiedRequest) // TODO: Check whether this is evil!
//    }
}
