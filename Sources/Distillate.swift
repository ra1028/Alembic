//
//  InsecureDistillate.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/13/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

public class Distillate<Value> {
    init() {}
    
    func _value() throws -> Value {
        fatalError("Abstract method")
    }
}

public extension Distillate {
    func map<T>(_ selector: (Value) throws -> T) throws -> T {
        return try selector(_value())
    }
    
    func map<T>(_ selector: @escaping (Value) throws -> T) -> InsecureDistillate<T> {
        return .init { try self.map(selector) }
    }
    
    func flatMap<T, U: Distillate<T>>(_ selector: (Value) throws -> U) throws -> T {
        return try map(selector)._value()
    }
    
    func flatMap<T, U: Distillate<T>>(_ selector: @escaping (Value) throws -> U) -> InsecureDistillate<T> {
        return .init { try self.flatMap(selector) }
    }
    
    func flatMap<T>(_ selector: (Value) throws -> T?) throws -> T {
        let optional = try map(selector)
        guard let v = optional else { throw DistillError.filteredValue(type: T.self, value: optional) }
        return v
    }
    
    func flatMap<T>(_ selector: @escaping (Value) throws -> T?) -> InsecureDistillate<T> {
        return .init { try self.flatMap(selector) }
    }
    
    func filter(_ predicate: (Value) throws -> Bool) throws -> Value {
        let v = try _value()
        guard try predicate(v) else { throw DistillError.filteredValue(type: Value.self, value: v) }
        return v
    }
    
    func filter(_ predicate: @escaping (Value) throws -> Bool) -> InsecureDistillate<Value> {
        return .init { try self.filter(predicate) }
    }
}
