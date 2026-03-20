//
//  SynchronizedBarrier.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation
 
public actor SynchronizedBarrier<Value> {

    public init(_ value: Value) {
        self.value = value
    }

    public func read() -> Value {
        value
    }

    @discardableResult
    public func withValue<T>(_ task: (inout Value) throws -> T) rethrows -> T {
        try task(&value)
    }

    private var value: Value

}
