//
//  InsecureDistillate.swift
//  Alembic
//
//  Created by Ryo Aoyama on 6/29/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public final class InsecureDistillate<Value>: Distillate<Value> {
    private let thunk: () throws -> Value
    
    init(_ thunk: () throws -> Value) {
        self.thunk = thunk
    }
    
    @warn_unused_result
    public override func value() throws -> Value {
        return try thunk()
    }
    
    @warn_unused_result
    public func to(_: Value.Type) throws -> Value {
        return try thunk()
    }
}

public extension InsecureDistillate {
    
}