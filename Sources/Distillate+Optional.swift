//
//  Distillate+Optional.swift
//  Alembic
//
//  Created by Ryo Aoyama on 2016/09/04.
//  Copyright © 2016年 Ryo Aoyama. All rights reserved.
//

public extension Distillate where Value: OptionalProtocol {
    func replaceNil(_ handler: () throws -> Value.Wrapped) throws -> Value.Wrapped {
        return try _value().optional ?? handler()
    }
    
    func replaceNil(_ handler: @escaping () throws -> Value.Wrapped) -> InsecureDistillate<Value.Wrapped> {
        return .init { try self.replaceNil(handler) }
    }
    
    func replaceNil(_ element: @autoclosure () -> Value.Wrapped) throws -> Value.Wrapped {
        return try replaceNil { element() }
    }
    
    func replaceNil(_ element: @autoclosure @escaping () -> Value.Wrapped) -> InsecureDistillate<Value.Wrapped> {
        return replaceNil { element() }
    }
    
    func filterNil() throws -> Value.Wrapped {
        return try filter { $0.optional != nil }.optional!
    }
    
    func filterNil() -> InsecureDistillate<Value.Wrapped> {
        return .init(filterNil)
    }
}
