//
//  Distillate+Collection.swift
//  Alembic
//
//  Created by Ryo Aoyama on 2016/09/04.
//  Copyright © 2016年 Ryo Aoyama. All rights reserved.
//

public extension Distillate where Value: Collection {
    func replaceEmpty(_ handler: () throws -> Value) throws -> Value {
        return try map { $0.isEmpty ? try handler() : $0 }
    }
    
    func replaceEmpty(_ handler: @escaping () throws -> Value) -> InsecureDistillate<Value> {
        return .init { try self.replaceEmpty(handler) }
    }
    
    func replaceEmpty(_ element: @autoclosure () -> Value) throws -> Value {
        return try replaceEmpty { element() }
    }
    
    func replaceEmpty(_ element: @autoclosure @escaping () -> Value) -> InsecureDistillate<Value> {
        return replaceEmpty { element() }
    }
    
    func filterEmpty() throws -> Value {
        return try filter { !$0.isEmpty }
    }
    
    func filterEmpty() -> InsecureDistillate<Value> {
        return .init(filterEmpty)
    }
}
