//
//  InsecureDistillate.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/13/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public class Distillate<Value>: DistillateType {
    init() {}
    
    @warn_unused_result
    public func value() throws -> Value {
        fatalError("Abstract method")
    }
}

public extension Distillate {
    static func just(@autoclosure(escaping) element: () -> Value) -> SecureDistillate<Value> {
        return SecureDistillate.init(element)
    }
    
    static func error(e: ErrorType) -> InsecureDistillate<Value> {
        return InsecureDistillate { throw e }
    }
    
    static func filter() -> InsecureDistillate<Value> {
        return error(DistillError.FilteredValue(type: Value.self, value: ()))
    }
}