//
//  Distillate.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/13/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public struct Distillate<Value>: DistillateType {
    private let thunk: () throws -> Value
    
    init(_ thunk: () throws -> Value) {
        self.thunk = thunk
    }
    
    @warn_unused_result
    public func to(_: Value.Type) throws -> Value {
        return try thunk()
    }
    
    @warn_unused_result
    public func value() throws -> Value {
        return try thunk()
    }
}

public struct SecureDistillate<Value>: DistillateType {
    private let thunk: () -> Value
    
    init(_ thunk: () -> Value) {
        self.thunk = thunk
    }
    
    @warn_unused_result
    public func to(_: Value.Type) -> Value {
        return thunk()
    }
    
    @warn_unused_result
    public func value() throws -> Value {
        return thunk()
    }
}

public protocol DistillateType {
    associatedtype Value
    
    func value() throws -> Value
}

public extension DistillateType {
    func map<T>(@noescape f: Value throws -> T) throws -> T {
        return try f(value())
    }
    
    @warn_unused_result
    func map<T>(f: Value throws -> T) -> Distillate<T> {
        return Distillate { try self.map(f) }
    }
    
    @warn_unused_result
    func flatMap<T: DistillateType>(f: Value throws -> T) throws -> T.Value {
        return try f(value()).value()
    }
    
    @warn_unused_result
    func flatMap<T: DistillateType>(f: Value throws -> T) -> Distillate<T.Value> {
        return Distillate { try self.flatMap(f) }
    }
    
    @warn_unused_result
    func flatMap<T>(f: Value throws -> Optional<T>) throws -> T {
        return try map(f).filterNil()
    }
    
    @warn_unused_result
    func flatMap<T>(f: Value throws -> Optional<T>) -> Distillate<T> {
        return Distillate { try self.flatMap(f) }
    }
    
    @warn_unused_result
    func filter(@noescape predicate: Value throws -> Bool) throws -> Value {
        return try map {
            if try predicate($0) { return $0 }
            throw DistilError.FilteredValue(type: Value.self, value: $0)
        }
    }
    
    @warn_unused_result
    func filter(predicate: Value throws -> Bool) -> Distillate<Value> {
        return Distillate { try self.filter(predicate) }
    }
    
    @warn_unused_result
    func catchReturn(@noescape handler: ErrorType -> Value) -> Value {
        do { return try value() }
        catch let e { return handler(e) }
    }
    
    @warn_unused_result
    func catchReturn(handler: ErrorType -> Value) -> SecureDistillate<Value> {
        return SecureDistillate { self.catchReturn(handler) }
    }
    
    @warn_unused_result
    func catchReturn(@autoclosure element: () -> Value) -> Value {
        return catchReturn { _ in element() }
    }
    
    @warn_unused_result
    func catchReturn(@autoclosure(escaping) element: () -> Value) -> SecureDistillate<Value> {
        return catchReturn { _ in element() }
    }
}

public extension DistillateType where Value: OptionalType {
    @warn_unused_result
    func replaceNil(@noescape handler: () throws -> Value.Wrapped) throws -> Value.Wrapped {
        return try value().optionalValue ?? handler()
    }
    
    @warn_unused_result
    func replaceNil(handler: () throws -> Value.Wrapped) -> Distillate<Value.Wrapped> {
        return Distillate { try self.replaceNil(handler) }
    }
    
    @warn_unused_result
    func replaceNil(@autoclosure element: () -> Value.Wrapped) throws -> Value.Wrapped {
        return try replaceNil(element)
    }
    
    @warn_unused_result
    func replaceNil(@autoclosure(escaping) element: () -> Value.Wrapped) -> Distillate<Value.Wrapped> {
        return replaceNil(element)
    }
    
    @warn_unused_result
    func filterNil() throws -> Value.Wrapped {
        return try filter { $0.optionalValue != nil }.optionalValue!
    }
    
    @warn_unused_result
    func filterNil() -> Distillate<Value.Wrapped> {
        return Distillate.init(filterNil)
    }
}

public extension DistillateType where Value: CollectionType {
    @warn_unused_result
    func replaceEmpty(@noescape handler: () throws -> Value) throws -> Value {
        return try map { $0.isEmpty ? try handler() : $0 }
    }
    
    @warn_unused_result
    func replaceEmpty(handler: () throws -> Value) -> Distillate<Value> {
        return Distillate { try self.replaceEmpty(handler) }
    }
    
    @warn_unused_result
    func replaceEmpty(@autoclosure element: () -> Value) throws -> Value {
        return try replaceEmpty(element)
    }
    
    @warn_unused_result
    func replaceEmpty(@autoclosure(escaping) element: () -> Value) -> Distillate<Value> {
       return replaceEmpty(element)
    }
    
    @warn_unused_result
    func filterEmpty() throws -> Value {
        return try filter { !$0.isEmpty }
    }
    
    @warn_unused_result
    func filterEmpty() -> Distillate<Value> {
        return Distillate.init(self.filterEmpty)
    }
}