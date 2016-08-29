//
//  SecureDistillate.swift
//  Alembic
//
//  Created by Ryo Aoyama on 6/29/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public final class SecureDistillate<Value>: Distillate<Value> {
    fileprivate let thunk: () -> Value
    
    init(_ thunk: @escaping () -> Value) {
        self.thunk = thunk
    }
    
    override func _value() throws -> Value {
        return value()
    }
}

public extension SecureDistillate {
    func value() -> Value {
        return thunk()
    }
    
     func to(_: Value.Type) -> Value {
        return value()
    }
    
    @discardableResult
    func success(_ handler: (Value) -> Void) -> SecureDistillate<Value> {
        let v = thunk()
        handler(v)
        return .init { v }
    }
}
