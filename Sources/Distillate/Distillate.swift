//
//  InsecureDistillate.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/13/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public class Distillate<Value> {
    init() {}
    
    func _value() throws -> Value {
        fatalError("Abstract method")
    }
}

public extension Distillate {
    func map<T>(_ f: (Value) throws -> T) throws -> T {
        return try f(_value())
    }
    
    func map<T>(_ f: @escaping (Value) throws -> T) -> InsecureDistillate<T> {
        return .init { try self.map(f) }
    }
    
    func flatMap<T, U: Distillate<T>>(_ f: (Value) throws -> U) throws -> T {
        return try map(f)._value()
    }
    
    func flatMap<T, U: Distillate<T>>(_ f: @escaping (Value) throws -> U) -> InsecureDistillate<T> {
        return .init { try self.flatMap(f) }
    }
    
    func flatMap<T>(_ f: (Value) throws -> T?) throws -> T {
        let optional = try map(f)
        guard let v = optional else { throw DistillError.filteredValue(type: T.self, value: optional) }
        return v
    }
    
    func flatMap<T>(_ f: @escaping (Value) throws -> T?) -> InsecureDistillate<T> {
        return .init { try self.flatMap(f) }
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
