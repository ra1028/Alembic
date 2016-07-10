//
//  SecureDistillate.swift
//  Alembic
//
//  Created by Ryo Aoyama on 6/29/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public final class SecureDistillate<Value>: Distillate<Value> {
    private let thunk: () -> Value
    
    init(_ thunk: () -> Value) {
        self.thunk = thunk
    }
    
    @warn_unused_result
    public override func value() throws -> Value {
        return thunk()
    }
    
    @warn_unused_result
    public func to(_: Value.Type) -> Value {
        return thunk()
    }
}

public extension SecureDistillate {
    func success(@noescape handler: Value -> Void) -> SecureDistillate<Value> {
        let v = self.thunk()
        handler(v)
        return SecureDistillate { v }
    }
}