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
    public func map<T>(@noescape f: Value throws -> T) throws -> T {
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
    func flatMap<T: DistillateType>(f: Value throws -> T) throws -> Distillate<T.Value> {
        return Distillate { try self.flatMap(f) }
    }
    
    @warn_unused_result
    func filter(@noescape predicate: Value -> Bool) throws -> Value {
        return try map {
            if predicate($0) { return $0 }
            throw DistilError.FilteredValue(type: Value.self, value: $0)
        }
    }
    
    @warn_unused_result
    func filter(predicate: Value -> Bool) -> Distillate<Value> {
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
    func catchReturn(@autoclosure value: () -> Value) -> Value {
        return catchReturn { _ in value() }
    }
    
    @warn_unused_result
    func catchReturn(@autoclosure(escaping) value: () -> Value) -> SecureDistillate<Value> {
        return catchReturn { _ in value() }
    }
}

public extension DistillateType where Value: OptionalType {
    @warn_unused_result
    func replaceNil(@noescape with: () -> Value.Wrapped) throws -> Value.Wrapped {
        return try value().optionalValue ?? with()
    }
    
    @warn_unused_result
    func replaceNil(with: () -> Value.Wrapped) -> Distillate<Value.Wrapped> {
        return Distillate { try self.replaceNil(with) }
    }
    
    @warn_unused_result
    func replaceNil(@autoclosure with: () -> Value.Wrapped) throws -> Value.Wrapped {
        return try replaceNil { with() }
    }
    
    @warn_unused_result
    func replaceNil(@autoclosure(escaping) with: () -> Value.Wrapped) -> Distillate<Value.Wrapped> {
        return replaceNil { with() }
    }
    
    @warn_unused_result
    func filterNil() throws -> Value.Wrapped {
        return try filter { $0.optionalValue != nil }.optionalValue!
    }
    
    @warn_unused_result
    func filterNil() -> Distillate<Value.Wrapped> {
        return Distillate { try self.filterNil() }
    }
}

public extension DistillateType where Value: CollectionType {
    @warn_unused_result
    func replaceEmpty(@noescape with: () -> Value) throws -> Value {
        return try map { $0.isEmpty ? with() : $0 }
    }
    
    @warn_unused_result
    func replaceEmpty(with: () -> Value) -> Distillate<Value> {
        return Distillate { try self.replaceEmpty(with) }
    }
    
    @warn_unused_result
    func replaceEmpty(@autoclosure with: () -> Value) throws -> Value {
        return try replaceEmpty { with() }
    }
    
    @warn_unused_result
    func replaceEmpty(@autoclosure(escaping) with: () -> Value) -> Distillate<Value> {
        return replaceEmpty { with() }
    }
    
    @warn_unused_result
    func filterEmpty() throws -> Value {
        return try filter { !$0.isEmpty }
    }
    
    @warn_unused_result
    func filterEmpty() -> Distillate<Value> {
        return Distillate { try self.filterEmpty() }
    }
}