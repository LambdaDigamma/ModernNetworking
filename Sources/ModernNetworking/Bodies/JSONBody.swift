//
//  HTTPLoader.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


public struct JSONBody: HTTPBody {
    
    public let isEmpty: Bool = false
    public var additionalHeaders = [
        "Content-Type": "application/json; charset=utf-8"
    ]

    public init <T: Encodable> (_ value: T, encoder: JSONEncoder = JSONEncoder()) {
        self._encode = { try encoder.encode(value) }
    }

    public func encode() throws -> Data {
        try _encode()
    }

    private let _encode: () throws -> Data

    /// Attention: use this only during debugging and testing
    public static func == (lhs: JSONBody, rhs: JSONBody) -> Bool {
        let lhsData = (try? lhs._encode()) ?? Data()
        let rhsData = (try? rhs._encode()) ?? Data()
        
        return lhsData == rhsData
    }
    
}

#if canImport(Combine)
import Combine
#endif

@available(OSX 10.15, *)
@available(iOS 13.0, *)
extension JSONBody {

    public init<T: Encodable, E: TopLevelEncoder>(_ value: T, encoder: E)
        where E.Output == Data {
        
        self._encode = { try encoder.encode(value) }
        
    }

}
