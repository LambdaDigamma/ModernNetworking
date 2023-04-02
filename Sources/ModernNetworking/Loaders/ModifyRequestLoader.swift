//
//  ModifyRequestLoader.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


public class ModifyRequestLoader: HTTPLoader {

    private let requestModifier: (HTTPRequest) -> HTTPRequest
    
    public init(_ requestModifier: @escaping (HTTPRequest) -> HTTPRequest) {
        self.requestModifier = requestModifier
        super.init()
    }

    public override func load(
        _ request: HTTPRequest,
        completion: @escaping HTTPResultHandler
    ) {
        let modifiedRequest = requestModifier(request)
        super.load(modifiedRequest, completion: completion)
    }
    
    public override func load(_ request: HTTPRequest) async -> HTTPResult {
        let modifiedRequest = requestModifier(request)
        return await super.load(modifiedRequest)
    }

}
