//
//  JSONType.swift
//  Alembic
//
//  Created by Ryo Aoyama on 2016/09/04.
//  Copyright © 2016年 Ryo Aoyama. All rights reserved.
//

import Foundation

public protocol JSONType {
    var currentPath: Path { get }
    
    func asJSON() -> JSON
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
    public func distil<T: Distillable>(_ path: Path = [], to: T.Type = T.self) throws -> T {
        let path = currentPath + path
        return try asJSON().distil(path, to: to)
    }
    
    public func distil<T: Distillable>(_ path: Path = [], to: [T].Type = [T].self) throws -> [T] {
        let path = currentPath + path
        return try asJSON().distil(path, to: to)
    }
    
    public func distil<T: Distillable>(_ path: Path = [], to: [String: T].Type = [String: T].self) throws -> [String: T] {
        let path = currentPath + path
        return try asJSON().distil(path, to: to)
    }
}

// MARK: - lazy distil functions

public extension JSONType {
    func distil<T: Distillable>(_ path: Path = [], to: T.Type = T.self) -> InsecureDistillate<T> {
        return .init { try self.distil(path) }
    }
    
    func distil<T: Distillable>(_ path: Path = [], to: [T].Type = [T].self) -> InsecureDistillate<[T]> {
        return .init { try self.distil(path) }
    }
    
    func distil<T: Distillable>(_ path: Path = [], to: [String: T].Type = [String: T].self) -> InsecureDistillate<[String: T]> {
        return .init { try self.distil(path) }
    }
}

// MARK: - distil option functions

public extension JSONType {
    func option<T: Distillable>(_ path: Path = [], to: T?.Type = (T?).self) throws -> T? {
        return try option(path) { try distil($0, to: T.self) }
    }
    
    func option<T: Distillable>(_ path: Path = [], to: [T]?.Type = ([T]?).self) throws -> [T]? {
        return try option(path) { try distil($0, to: [T].self) }
    }
    
    func option<T: Distillable>(_ path: Path = [], to: [String: T]?.Type = ([String: T]?).self) throws -> [String: T]? {
        return try option(path) { try distil($0, to: [String: T].self) }
    }
}

// MARK: - lazy distil option functions

public extension JSONType {
    func option<T: Distillable>(_ path: Path = [], to: T?.Type = (T?).self) -> InsecureDistillate<T?> {
        return .init { try self.option(path) }
    }
    
    func option<T: Distillable>(_ path: Path = [], to: [T]?.Type = ([T]?).self) -> InsecureDistillate<[T]?> {
        return .init { try self.option(path) }
    }
    
    func option<T: Distillable>(_ path: Path = [], to: [String: T]?.Type = ([String: T]?).self) -> InsecureDistillate<[String: T]?> {
        return .init { try self.option(path) }
    }
}

// MARK: - private functions

private extension JSONType {
    func option<T>(_ path: Path, distil: (Path) throws -> T) throws -> T? {
        do {
            return try distil(path)
        } catch let DistillError.missingPath(missing) where missing == currentPath + path {
            return nil
        }
    }
}
