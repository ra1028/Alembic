//
//  JSONType.swift
//  Alembic
//
//  Created by Ryo Aoyama on 2016/09/04.
//  Copyright © 2016年 Ryo Aoyama. All rights reserved.
//

public protocol JSONType {
    func distil<T: Distillable>(_ path: Path, as: T.Type) throws -> T
    func option<T: Distillable>(_ path: Path, as: T?.Type) throws -> T?
}

// MARK: - distil functions with type constraints

public extension JSONType {
    func to<T: Distillable>(_: T.Type) throws -> T {
        return try distil()
    }
    
    func to<T: Distillable>(_: [T].Type) throws -> [T] {
        return try distil()
    }
    
    func to<T: Distillable>(_: [String: T].Type) throws -> [String: T] {
        return try distil()
    }
}

// MARK: - distil functions

public extension JSONType {
    func distil<T: Distillable>(_ path: Path = []) throws -> T {
        return try distil(path, as: T.self)
    }
    
    func distil<T: Distillable>(as: T.Type) throws -> T {
        return try distil([], as: `as`)
    }
    
    func distil<T: Distillable>(_ path: Path = [], as: [T].Type = [T].self) throws -> [T] {
        return try .distil(json: distil(path))
    }
    
    func distil<T: Distillable>(_ path: Path = [], as: [String: T].Type = [String: T].self) throws -> [String: T] {
        return try .distil(json: distil(path))
    }
}

// MARK: - lazy distil functions

public extension JSONType {
    func distil<T: Distillable>(_ path: Path = [], as: T.Type = T.self) -> InsecureDistillate<T> {
        return .init { try self.distil(path) }
    }
    
    func distil<T: Distillable>(_ path: Path = [], as: [T].Type = [T].self) -> InsecureDistillate<[T]> {
        return .init { try self.distil(path) }
    }
    
    func distil<T: Distillable>(_ path: Path = [], as: [String: T].Type = [String: T].self) -> InsecureDistillate<[String: T]> {
        return .init { try self.distil(path) }
    }
}

// MARK: - distil option functions

public extension JSONType {
    func option<T: Distillable>(_ path: Path = []) throws -> T? {
        return try option(path, as: (T?).self)
    }
    
    func option<T: Distillable>(as: T?.Type) throws -> T? {
        return try option([], as: `as`)
    }
    
    func option<T: Distillable>(_ path: Path = [], as: [T]?.Type = ([T]?).self) throws -> [T]? {
        return try option(path).map([T].distil)
    }
    
    func option<T: Distillable>(_ path: Path = [], as: [String: T]?.Type = ([String: T]?).self) throws -> [String: T]? {
        return try option(path).map([String: T].distil)
    }
}

// MARK: - lazy distil option functions

public extension JSONType {
    func option<T: Distillable>(_ path: Path = [], as: T?.Type = (T?).self) -> InsecureDistillate<T?> {
        return .init { try self.option(path) }
    }
    
    func option<T: Distillable>(_ path: Path = [], as: [T]?.Type = ([T]?).self) -> InsecureDistillate<[T]?> {
        return .init { try self.option(path) }
    }
    
    func option<T: Distillable>(_ path: Path = [], as: [String: T]?.Type = ([String: T]?).self) -> InsecureDistillate<[String: T]?> {
        return .init { try self.option(path) }
    }
}
