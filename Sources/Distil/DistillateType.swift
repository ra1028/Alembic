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
    func map<T>(@noescape f: Value throws -> T) throws -> T {
        return try f(value())
    }
    
    @warn_unused_result
    func map<T>(f: Value throws -> T) -> InsecureDistillate<T> {
        return InsecureDistillate { try self.map(f) }
    }
    
    @warn_unused_result
    func flatMap<T: DistillateType>(f: Value throws -> T) throws -> T.Value {
        return try f(value()).value()
    }
    
    @warn_unused_result
    func flatMap<T: DistillateType>(f: Value throws -> T) -> InsecureDistillate<T.Value> {
        return InsecureDistillate { try self.flatMap(f) }
    }
    
    @warn_unused_result
    func flatMap<T>(f: Value throws -> Optional<T>) throws -> T {
        return try map(f).filterNil()
    }
    
    @warn_unused_result
    func flatMap<T>(f: Value throws -> Optional<T>) -> InsecureDistillate<T> {
        return InsecureDistillate { try self.flatMap(f) }
    }
    
    @warn_unused_result
    func filter(@noescape predicate: Value throws -> Bool) throws -> Value {
        let v = try value()
        if try predicate(v) { return v }
        throw DistillError.FilteredValue(type: Value.self, value: v)
    }
    
    @warn_unused_result
    func filter(predicate: Value throws -> Bool) -> InsecureDistillate<Value> {
        return InsecureDistillate { try self.filter(predicate) }
    }
}

public extension DistillateType where Value: OptionalType {
    @warn_unused_result
    func replaceNil(@noescape handler: () throws -> Value.Wrapped) throws -> Value.Wrapped {
        return try value().optionalValue ?? handler()
    }
    
    @warn_unused_result
    func replaceNil(handler: () throws -> Value.Wrapped) -> InsecureDistillate<Value.Wrapped> {
        return InsecureDistillate { try self.replaceNil(handler) }
    }
    
    @warn_unused_result
    func replaceNil(@autoclosure element: () -> Value.Wrapped) throws -> Value.Wrapped {
        return try replaceNil { element() }
    }
    
    @warn_unused_result
    func replaceNil(@autoclosure(escaping) element: () -> Value.Wrapped) -> InsecureDistillate<Value.Wrapped> {
        return replaceNil { element() }
    }
    
    @warn_unused_result
    func filterNil() throws -> Value.Wrapped {
        return try filter { $0.optionalValue != nil }.optionalValue!
    }
    
    @warn_unused_result
    func filterNil() -> InsecureDistillate<Value.Wrapped> {
        return InsecureDistillate.init(filterNil)
    }
}

public extension DistillateType where Value: CollectionType {
    @warn_unused_result
    func replaceEmpty(@noescape handler: () throws -> Value) throws -> Value {
        return try map { $0.isEmpty ? try handler() : $0 }
    }
    
    @warn_unused_result
    func replaceEmpty(handler: () throws -> Value) -> InsecureDistillate<Value> {
        return InsecureDistillate { try self.replaceEmpty(handler) }
    }
    
    @warn_unused_result
    func replaceEmpty(@autoclosure element: () -> Value) throws -> Value {
        return try replaceEmpty { element() }
    }
    
    @warn_unused_result
    func replaceEmpty(@autoclosure(escaping) element: () -> Value) -> InsecureDistillate<Value> {
        return replaceEmpty { element() }
    }
    
    @warn_unused_result
    func filterEmpty() throws -> Value {
        return try filter { !$0.isEmpty }
    }
    
    @warn_unused_result
    func filterEmpty() -> InsecureDistillate<Value> {
        return InsecureDistillate.init(filterEmpty)
    }
}