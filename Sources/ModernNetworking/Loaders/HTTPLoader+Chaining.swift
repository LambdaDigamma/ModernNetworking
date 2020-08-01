//
//  HTTPLoader+Chaining.swift
//  
//
//  Created by Lennart Fischer on 01.08.20.
//

import Foundation


precedencegroup LoaderChainingPrecedence {
    higherThan: NilCoalescingPrecedence
    associativity: right
}

infix operator --> : LoaderChainingPrecedence

@available(OSX 10.15, *)
@available(iOS 13.0, *)
@discardableResult
public func --> (lhs: HTTPLoader?, rhs: HTTPLoader?) -> HTTPLoader? {
    lhs?.nextLoader = rhs
    return lhs ?? rhs
}
