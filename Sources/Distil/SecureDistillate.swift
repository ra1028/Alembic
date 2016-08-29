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
    
    public override func value() throws -> Value {
        return thunk()
    }
        
    public func to(_: Value.Type) -> Value {
        return thunk()
    }
}

public extension SecureDistillate {
    @discardableResult
    func success(_ handler: (Value) -> Void) -> SecureDistillate<Value> {
        let v = thunk()
        handler(v)
        return .init { v }
    }
}
