//
//  DistillSubscripted.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/29/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public final class DistillSubscripted {
    fileprivate let j: JSON
    fileprivate let path: JSONPath
    
    public subscript(path: JSONPathElement) -> DistillSubscripted {
        return .init(j, self.path + JSONPath(path))
    }
    
    public subscript(path: JSONPathElement...) -> DistillSubscripted {
        return .init(j, self.path + JSONPath(path))
    }
    
    init(_ j: JSON, _ path: JSONPath) {
        self.j = j
        self.path = path
    }    
}

public extension DistillSubscripted {
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

// MARK: - distil value functions

public extension DistillSubscripted {
    func distil<T: Distillable>(_: T.Type = T.self) throws -> T {
        return try j.distil(path)
    }
    
    func distil<T: Distillable>(_: T.Type = T.self) -> InsecureDistillate<T> {
        return .init { try self.distil() }
    }
}

// MARK: - distil option value functions

public extension DistillSubscripted {
    func option<T: Distillable>(_: T?.Type = (T?).self) throws -> T? {
        return try j.option(path)
    }
    
    func option<T: Distillable>(_: T?.Type = (T?).self) -> InsecureDistillate<T?> {
        return .init { try self.option() }
    }
}

// MARK: - distil array functions

public extension DistillSubscripted {
    func distil<T: Distillable>(_: [T].Type = [T].self) throws -> [T] {
        return try j.distil(path)
    }
    
    func distil<T: Distillable>(_: [T].Type = [T].self) -> InsecureDistillate<[T]> {
        return .init { try self.distil() }
    }
}

// MARK: - distil option array functions

public extension DistillSubscripted {
    func option<T: Distillable>(_: [T]?.Type = ([T]?).self) throws -> [T]? {
        return try j.option(path)
    }
    
    func option<T: Distillable>(_: [T]?.Type = ([T]?).self) -> InsecureDistillate<[T]?> {
        return .init { try self.option() }
    }
}

// MARK: - distil dictionary functions

public extension DistillSubscripted {
    func distil<T: Distillable>(_: [String: T].Type = [String: T].self) throws -> [String: T] {
        return try j.distil(path)
    }
    
    func distil<T: Distillable>(_: [String: T].Type = [String: T].self) -> InsecureDistillate<[String: T]> {
        return .init { try self.distil() }
    }
}

// MARK: - distil option dictionary functions

public extension DistillSubscripted {
    func option<T: Distillable>(_: [String: T]?.Type = ([String: T]?).self) throws -> [String: T]? {
        return try j.option(path)
    }
    
    func option<T: Distillable>(_: [String: T]?.Type = ([String: T]?).self) -> InsecureDistillate<[String: T]?> {
        return .init { try self.option() }
    }
}
