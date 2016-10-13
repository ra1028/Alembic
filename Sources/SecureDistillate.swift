//
//  SecureDistillate.swift
//  Alembic
//
//  Created by Ryo Aoyama on 6/29/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

public final class SecureDistillate<Value>: Distillate<Value> {
    private let evaluate: () -> Value
    private lazy var cached: Value = self.evaluate()
    
    init(_ evaluate: @escaping () -> Value) {
        self.evaluate = evaluate
    }
    
    convenience init(_ value: @autoclosure @escaping () -> Value) {
        self.init(value)
    }
    
    override func _value() throws -> Value {
        return value()
    }
    
    public func value() -> Value {
        return cached
    }
}

public extension SecureDistillate {
    @discardableResult
    func value(_ handler: (Value) -> Void) -> SecureDistillate<Value> {
        let v = value()
        handler(v)
        return .init(v)
    }
    
    func to(_: Value.Type) -> Value {
        return value()
    }
}
