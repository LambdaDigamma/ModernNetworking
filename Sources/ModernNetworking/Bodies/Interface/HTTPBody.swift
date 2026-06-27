//
//  HTTPBody.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


nonisolated public protocol HTTPBody: Sendable {

    var isEmpty: Bool { get }
    var additionalHeaders: [String: String] { get }

    func encode() throws -> Data

}

nonisolated extension HTTPBody {

    public var isEmpty: Bool {
        false
    }

    public var additionalHeaders: [String: String] {
        [:]
    }

}
