//
//  EmptyBody.swift
//  24doors
//
//  Created by Lennart Fischer on 17.07.20.
//  Copyright © 2020 LambdaDigamma. All rights reserved.
//

import Foundation

public struct EmptyBody: HTTPBody {
    
    public let isEmpty = true
    
    public init() { }
    public func encode() throws -> Data { Data() }
    
}
