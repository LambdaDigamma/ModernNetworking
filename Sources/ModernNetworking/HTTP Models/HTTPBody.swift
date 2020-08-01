//
//  HTTPBody.swift
//  24doors
//
//  Created by Lennart Fischer on 17.07.20.
//  Copyright © 2020 LambdaDigamma. All rights reserved.
//

import Foundation

public protocol HTTPBody {
    
    var isEmpty: Bool { get }
    var additionalHeaders: [String: String] { get }
    func encode() throws -> Data
    
}

extension HTTPBody {
    
    public var isEmpty: Bool { return false }
    public var additionalHeaders: [String: String] { return [:] }
    
}
