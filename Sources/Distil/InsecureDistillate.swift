//
//  InsecureDistillate.swift
//  Alembic
//
//  Created by Ryo Aoyama on 6/29/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public final class InsecureDistillate<Value>: Distillate<Value> {
    fileprivate let thunk: () throws -> Value
    
    init(_ thunk: @escaping () throws -> Value) {
        self.thunk = thunk
    }
    
    public override func value() throws -> Value {
        return try thunk()
    }
}

public extension InsecureDistillate {
    @discardableResult
    func success(_ handler: (Value) -> Void) -> InsecureDistillate<Value> {
        do {
            let v = try value()
            handler(v)
            return InsecureDistillate { v }
        } catch let e {
            return InsecureDistillate { throw e }
        }
    }
    
    @discardableResult
    func failure(_ handler: (Error) -> Void) -> InsecureDistillate<Value> {
        do {
            let v = try value()
            return InsecureDistillate { v }
        } catch let e {
            handler(e)
            return InsecureDistillate { throw e }
        }
    }
    
    public func to(_: Value.Type) throws -> Value {
        return try thunk()
    }
    
    func recover(_ handler: (Error) -> Value) -> Value {
        do { return try value() }
        catch let e { return handler(e) }
    }
    
    func recover(_ handler: @escaping (Error) -> Value) -> SecureDistillate<Value> {
        return SecureDistillate { self.recover(handler) }
    }
    
    func recover(_ element: @autoclosure () -> Value) -> Value {
        return recover { _ in element() }
    }
    
    func recover( _ element: @autoclosure @escaping () -> Value) -> SecureDistillate<Value> {
        return recover { _ in element() }
    }
    
    func mapError(_ f: (Error) throws -> Error) throws -> Value {
        do { return try value() }
        catch let e { throw try f(e) }
    }
    
    func mapError(_ f: @escaping (Error) throws -> Error) -> InsecureDistillate<Value> {
        return InsecureDistillate { try self.mapError(f) }
    }
    
    func flatMapError<T: DistillateType>(_ f: (Error) throws -> T) throws -> Value where T.Value == Value {
        do { return try value() }
        catch let e { return try f(e).value() }
    }
    
    func flatMapError<T: DistillateType>(_ f: @escaping (Error) throws -> T) -> InsecureDistillate<Value> where T.Value == Value {
        return InsecureDistillate { try self.flatMapError(f) }
    }
}
