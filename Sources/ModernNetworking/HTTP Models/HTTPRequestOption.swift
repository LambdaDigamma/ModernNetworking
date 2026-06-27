//
//  HTTPRequestOption.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


nonisolated public protocol HTTPRequestOption {

    associatedtype Value: Sendable

    /// The value to use if a request does not provide a customized value
    static var defaultOptionValue: Value { get }

}
