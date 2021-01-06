//
//  EmptyBody.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


public struct EmptyBody: HTTPBody {

    public let isEmpty = true

    public init() {}

    public func encode() throws -> Data { Data() }

}
