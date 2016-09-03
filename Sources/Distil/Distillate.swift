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
    static var filter: InsecureDistillate<Value> {
        return error(DistillError.filteredValue(type: Value.self, value: ()))
    }
    
    static func error(_ error: Error) -> InsecureDistillate<Value> {
        return .init { throw error }
    }
    
    static func just(_ element: @autoclosure @escaping () -> Value) -> SecureDistillate<Value> {
        return .init(element)
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

public extension Distillate where Value: OptionalType {
    func replaceNil(_ handler: () throws -> Value.Wrapped) throws -> Value.Wrapped {
        return try _value().optionalValue ?? handler()
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
        return try filter { $0.optionalValue != nil }.optionalValue!
    }
    
    func filterNil() -> InsecureDistillate<Value.Wrapped> {
        return .init(filterNil)
    }
}

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
