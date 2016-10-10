//
//  InsecureDistillate.swift
//  Alembic
//
//  Created by Ryo Aoyama on 6/29/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

public final class InsecureDistillate<Value>: Distillate<Value> {
    fileprivate let thunk: () throws -> Value
    
    init(_ thunk: @escaping () throws -> Value) {
        self.thunk = thunk
    }
    
    override func _value() throws -> Value {
        return try value()
    }
}

public extension InsecureDistillate {
    func value() throws -> Value {
        return try thunk()
    }
    
    @discardableResult
    func value(_ handler: (Value) -> Void) -> InsecureDistillate<Value> {
        do {
            let v = try value()
            handler(v)
            return .init { v }
        } catch let e {
            return .init { throw e }
        }
    }
    
    @discardableResult
    func error(_ handler: (Error) -> Void) -> InsecureDistillate<Value> {
        do {
            let v = try value()
            return .init { v }
        } catch let e {
            handler(e)
            return .init { throw e }
        }
    }
    
    func to(_: Value.Type) throws -> Value {
        return try value()
    }
    
    func `catch`(_ handler: (Error) -> Value) -> Value {
        do { return try value() }
        catch let e { return handler(e) }
    }
    
    func `catch`(_ handler: @escaping (Error) -> Value) -> SecureDistillate<Value> {
        return .init { self.catch(handler) }
    }
    
    func `catch`(_ element: @autoclosure () -> Value) -> Value {
        return self.catch { _ in element() }
    }
    
    func `catch`( _ element: @autoclosure @escaping () -> Value) -> SecureDistillate<Value> {
        return self.catch { _ in element() }
    }
    
    func mapError(_ f: (Error) throws -> Error) throws -> Value {
        do { return try value() }
        catch let e { throw try f(e) }
    }
    
    func mapError(_ f: @escaping (Error) throws -> Error) -> InsecureDistillate<Value> {
        return .init { try self.mapError(f) }
    }
    
    func flatMapError<T: Distillate<Value>>(_ f: (Error) throws -> T) throws -> Value {
        do { return try value() }
        catch let e { return try f(e)._value() }
    }
    
    func flatMapError<T: Distillate<Value>>(_ f: @escaping (Error) throws -> T) -> InsecureDistillate<Value> {
        return .init { try self.flatMapError(f) }
    }
}
