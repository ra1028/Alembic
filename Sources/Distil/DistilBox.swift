//
//  DistilBox.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/13/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public struct DistilBox<Value>: DistilBoxType {
    private let process: () throws -> Value
    
    init(_ process: () throws -> Value) {
        self.process = process
    }
    
    @warn_unused_result
    public func to(_: Value.Type) throws -> Value {
        return try process()
    }
    
    @warn_unused_result
    public func value() throws -> Value {
        return try process()
    }
}

public struct DistilSecureBox<Value>: DistilBoxType {
    private let process: () -> Value
    
    init(_ process: () -> Value) {
        self.process = process
    }
    
    @warn_unused_result
    public func to(_: Value.Type) -> Value {
        return process()
    }
    
    @warn_unused_result
    public func value() throws -> Value {
        return process()
    }
}

public protocol DistilBoxType {
    associatedtype Value
    
    func value() throws -> Value
}

public extension DistilBoxType {
    public func map<T>(@noescape f: Value throws -> T) throws -> T {
        return try f(value())
    }
    
    @warn_unused_result
    func map<T>(f: Value throws -> T) -> DistilBox<T> {
        return DistilBox { try self.map(f) }
    }
    
    @warn_unused_result
    func flatMap<T, S: DistilBoxType where S.Value == T>(f: Value throws -> S) throws -> T {
        return try f(value()).value()
    }
    
    @warn_unused_result
    func flatMap<T, S: DistilBoxType where S.Value == T>(f: Value throws -> S) throws -> DistilBox<T> {
        return DistilBox { try self.flatMap(f) }
    }
    
    @warn_unused_result
    func filter(@noescape predicate: Value -> Bool) throws -> Value {
        return try map {
            if predicate($0) { return $0 }
            throw DistilError.FilteredValue($0)
        }
    }
    
    @warn_unused_result
    func filter(predicate: Value -> Bool) -> DistilBox<Value> {
        return DistilBox { try self.filter(predicate) }
    }
    
    @warn_unused_result
    func catchUp(@noescape with: () -> Value) -> Value {
        do { return try value() }
        catch { return with() }
    }
    
    @warn_unused_result
    func catchUp(with: () -> Value) -> DistilSecureBox<Value> {
        return DistilSecureBox { self.catchUp(with) }
    }
    
    @warn_unused_result
    func catchUp(@autoclosure with: () -> Value) -> Value {
        return catchUp { with() }
    }
    
    @warn_unused_result
    func catchUp(with: Value) -> DistilSecureBox<Value> {
        return catchUp { with }
    }
}

public extension DistilBoxType where Value: OptionalType {
    @warn_unused_result
    func remapNil(@noescape with: () -> Value.Wrapped) throws -> Value.Wrapped {
        return try map { $0.optionalValue ?? with() }
    }
    
    @warn_unused_result
    func remapNil(with: () -> Value.Wrapped) -> DistilBox<Value.Wrapped> {
        return DistilBox { try self.remapNil(with) }
    }
    
    @warn_unused_result
    func remapNil(@autoclosure with: () -> Value.Wrapped) throws -> Value.Wrapped {
        return try remapNil { with() }
    }
    
    @warn_unused_result
    func remapNil(with: Value.Wrapped) -> DistilBox<Value.Wrapped> {
        return remapNil { with }
    }
    
    @warn_unused_result
    func ensure(@noescape with: () -> Value.Wrapped) -> Value.Wrapped {
        do { return try remapNil { with() } }
        catch { return with() }
    }
    
    @warn_unused_result
    func ensure(with: () -> Value.Wrapped) -> DistilSecureBox<Value.Wrapped> {
        return DistilSecureBox { self.ensure(with) }
    }
    
    @warn_unused_result
    func ensure(@autoclosure with: () -> Value.Wrapped) -> Value.Wrapped {
        return ensure { with() }
    }
    
    @warn_unused_result
    func ensure(with: Value.Wrapped) -> DistilSecureBox<Value.Wrapped> {
        return ensure { with }
    }
    
    @warn_unused_result
    func filterNil() throws -> Value.Wrapped {
        return try filter { $0.optionalValue != nil }.optionalValue!
    }
    
    @warn_unused_result
    func filterNil() -> DistilBox<Value.Wrapped> {
        return DistilBox { try self.filterNil() }
    }
}

public extension DistilBoxType where Value: CollectionType {
    @warn_unused_result
    func remapEmpty(@noescape with: () -> Value) throws -> Value {
        return try map {
            if $0.isEmpty { return with() }
            return $0
        }
    }
    
    @warn_unused_result
    func remapEmpty(with: () -> Value) -> DistilBox<Value> {
        return DistilBox { try self.remapEmpty(with) }
    }
    
    @warn_unused_result
    func remapEmpty(@autoclosure with: () -> Value) throws -> Value {
        return try remapEmpty { with() }
    }
    
    @warn_unused_result
    func remapEmpty(with: Value) -> DistilBox<Value> {
        return remapEmpty { with }
    }
    
    @warn_unused_result
    func filterEmpty() throws -> Value {
        return try filter { !$0.isEmpty }
    }
    
    @warn_unused_result
    func filterEmpty() -> DistilBox<Value> {
        return DistilBox { try self.filterEmpty() }
    }
}