//
//  JSONType.swift
//  Alembic
//
//  Created by Ryo Aoyama on 2016/09/04.
//  Copyright © 2016年 Ryo Aoyama. All rights reserved.
//

import Foundation

public protocol JSONType {
    func distil<T: Distillable>(to: T.Type) throws -> T
    func distil<T: Distillable>(to: [T].Type) throws -> [T]
    func distil<T: Distillable>(to: [String: T].Type) throws -> [String: T]
    func option<T: Distillable>(to: T?.Type) throws -> T?
    func option<T: Distillable>(to: [T]?.Type) throws -> [T]?
    func option<T: Distillable>(to: [String: T]?.Type) throws -> [String: T]?
}

// MARK: - distil functions with type constraints

public extension JSONType {
    func to<T: Distillable>(_: T.Type) throws -> T {
        return try distil(to: T.self)
    }
    
    func to<T: Distillable>(_: [T].Type) throws -> [T] {
        return try distil(to: [T].self)
    }
    
    func to<T: Distillable>(_: [String: T].Type) throws -> [String: T] {
        return try distil(to: [String: T].self)
    }
}

// MARK: - distil functions

public extension JSONType {
    func distil<T: Distillable>(to: T.Type = T.self) -> InsecureDistillate<T> {
        return .init { try self.distil(to: T.self) }
    }
    
    func distil<T: Distillable>(to: [T].Type = [T].self) -> InsecureDistillate<[T]> {
        return .init { try self.distil(to: [T].self) }
    }
    
    func distil<T: Distillable>(to: [String: T].Type = [String: T].self) -> InsecureDistillate<[String: T]> {
        return .init { try self.distil(to: [String: T].self) }
    }
}

// MARK: - distil option functions

public extension JSONType {
    func option<T: Distillable>(to: T?.Type = (T?).self) -> InsecureDistillate<T?> {
        return .init { try self.option(to: (T?).self) }
    }
    
    func option<T: Distillable>(to: [T]?.Type = ([T]?).self) -> InsecureDistillate<[T]?> {
        return .init { try self.option(to: ([T]?).self) }
    }
    
    func option<T: Distillable>(to: [String: T]?.Type = ([String: T]?).self) -> InsecureDistillate<[String: T]?> {
        return .init { try self.option(to: ([String: T]?).self) }
    }
}
