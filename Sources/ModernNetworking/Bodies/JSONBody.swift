//
//  HTTPLoader.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


public struct JSONBody<T: Encodable>: HTTPBody {
    
    public let isEmpty: Bool = false
    public var additionalHeaders = [
        "Content-Type": "application/json; charset=utf-8"
    ]

    private let encoder: JSONEncoder
    private let value: T
    
    public init(_ value: T, encoder: JSONEncoder? = nil) {
        self.encoder = encoder ?? JSONEncoder()
        self.value = value
//        self._encode = { try encoder.encode(value) }
    }

    public func encode() throws -> Data {
        try encoder.encode(value)
//        try _encode()
    }

//    private let _encode: () throws -> Data

    /// Attention: use this only during debugging and testing
    public static func == (lhs: JSONBody, rhs: JSONBody) -> Bool {
        let lhsData = (try? lhs.encode()) ?? Data()
        let rhsData = (try? rhs.encode()) ?? Data()
        
        return lhsData == rhsData
    }
    
}

//#if canImport(Combine)
//import Combine
//#endif
//
//@available(OSX 10.15, *)
//@available(iOS 13.0, *)
//extension JSONBody {
//
//    public init<T: Encodable, E: TopLevelEncoder>(_ value: T, encoder: E)
//        where E.Output == Data {
//        
//        self._encode = { try encoder.encode(value) }
//        
//    }
//
//}
