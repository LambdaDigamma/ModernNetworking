//
//  DataBody.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


public struct DataBody: HTTPBody, Equatable {
    
    private let data: Data
    
    public var isEmpty: Bool { data.isEmpty }
    public var additionalHeaders: [String: String]

    public init(_ data: Data, additionalHeaders: [String: String] = [:]) {
        self.data = data
        self.additionalHeaders = additionalHeaders
    }

    public func encode() throws -> Data { data }

    public static func == (lhs: DataBody, rhs: DataBody) -> Bool {
        return lhs.data == rhs.data
    }
    
}
