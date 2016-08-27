//
//  DistillateType.swift
//  Alembic
//
//  Created by Ryo Aoyama on 6/29/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public protocol DistillateType {
    associatedtype Value
    
    func value() throws -> Value
}

public extension DistillateType {
    func map<T>(_ f: (Value) throws -> T) throws -> T {
        return try f(value())
    }
    
    func map<T>(_ f: @escaping (Value) throws -> T) -> InsecureDistillate<T> {
        return InsecureDistillate { try self.map(f) }
    }
    
    func flatMap<T: DistillateType>(_ f: (Value) throws -> T) throws -> T.Value {
        return try f(value()).value()
    }
    
    func flatMap<T: DistillateType>(_ f: @escaping (Value) throws -> T) -> InsecureDistillate<T.Value> {
        return InsecureDistillate { try self.flatMap(f) }
    }
    
    func flatMap<T>(_ f: (Value) throws -> Optional<T>) throws -> T {
        let optional = try map(f)
        guard let v = optional else { throw DistillError.filteredValue(type: T.self, value: optional) }
        return v
    }
    
    func flatMap<T>(_ f: @escaping (Value) throws -> Optional<T>) -> InsecureDistillate<T> {
        return InsecureDistillate { try self.flatMap(f) }
    }
    
    func filter(_ predicate: (Value) throws -> Bool) throws -> Value {
        let v = try value()
        guard try predicate(v) else { throw DistillError.filteredValue(type: Value.self, value: v) }
        return v
    }
    
    func filter(_ predicate: @escaping (Value) throws -> Bool) -> InsecureDistillate<Value> {
        return InsecureDistillate { try self.filter(predicate) }
    }
}

public extension DistillateType where Value: OptionalType {
    func replaceNil(_ handler: () throws -> Value.Wrapped) throws -> Value.Wrapped {
        return try value().optionalValue ?? handler()
    }
    
    func replaceNil(_ handler: @escaping () throws -> Value.Wrapped) -> InsecureDistillate<Value.Wrapped> {
        return InsecureDistillate { try self.replaceNil(handler) }
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
        return InsecureDistillate.init(filterNil)
    }
}

public extension DistillateType where Value: Collection {
    func replaceEmpty(_ handler: () throws -> Value) throws -> Value {
        return try map { $0.isEmpty ? try handler() : $0 }
    }
    
    func replaceEmpty(_ handler: @escaping () throws -> Value) -> InsecureDistillate<Value> {
        return InsecureDistillate { try self.replaceEmpty(handler) }
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
        return InsecureDistillate.init(filterEmpty)
    }
}
