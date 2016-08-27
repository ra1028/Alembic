//
//  InsecureDistillate.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/13/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

open class Distillate<Value>: DistillateType {
    init() {}
    
    @warn_unused_result
    open func value() throws -> Value {
        fatalError("Abstract method")
    }
}

public extension Distillate {
    static func just( _ element: @autoclosure @escaping () -> Value) -> SecureDistillate<Value> {
        return SecureDistillate.init(element)
    }
    
    static func error(_ e: Error) -> InsecureDistillate<Value> {
        return InsecureDistillate { throw e }
    }
    
    static func filter() -> InsecureDistillate<Value> {
        return error(DistillError.filteredValue(type: Value.self, value: ()))
    }
}
