//
//  DistilSubscripted.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/29/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public struct DistilSubscripted {
    private let j: JSON
    private let path: JSONPath
    
    init(_ j: JSON, _ path: JSONPath) {
        self.j = j
        self.path = path
    }    
}

public extension DistilSubscripted {
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

public extension DistilSubscripted {
    func distil<T: Distillable>(_: T.Type = T.self) throws -> T {
        return try j.distil(path)
    }
    
    func distil<T: Distillable>(_: T.Type = T.self) -> Distillate<T> {
        return Distillate { try self.distil() }
    }
}

// MARK: - distil option value functions

public extension DistilSubscripted {
    func option<T: Distillable>(_: Optional<T>.Type = Optional<T>.self) throws -> Optional<T> {
        return try j.option(path)
    }
    
    func option<T: Distillable>(_: Optional<T>.Type = Optional<T>.self) -> Distillate<Optional<T>> {
        return Distillate { try self.option() }
    }
}

// MARK: - distil array functions

public extension DistilSubscripted {
    func distil<T: Distillable>(_: [T].Type = [T].self) throws -> [T] {
        return try j.distil(path)
    }
    
    func distil<T: Distillable>(_: [T].Type = [T].self) -> Distillate<[T]> {
        return Distillate { try self.distil() }
    }
}

// MARK: - distil option array functions

public extension DistilSubscripted {
    func option<T: Distillable>(_: Optional<[T]>.Type = Optional<[T]>.self) throws -> Optional<[T]> {
        return try j.option(path)
    }
    
    func option<T: Distillable>(_: Optional<[T]>.Type = Optional<[T]>.self) -> Distillate<Optional<[T]>> {
        return Distillate { try self.option() }
    }
}

// MARK: - distil dictionary functions

public extension DistilSubscripted {
    func distil<T: Distillable>(_: [String: T].Type = [String: T].self) throws -> [String: T] {
        return try j.distil(path)
    }
    
    func distil<T: Distillable>(_: [String: T].Type = [String: T].self) -> Distillate<[String: T]> {
        return Distillate { try self.distil() }
    }
}

// MARK: - distil option dictionary functions

public extension DistilSubscripted {
    func option<T: Distillable>(_: Optional<[String: T]>.Type = Optional<[String: T]>.self) throws -> Optional<[String: T]> {
        return try j.option(path)
    }
    
    func option<T: Distillable>(_: Optional<[String: T]>.Type = Optional<[String: T]>.self) -> Distillate<Optional<[String: T]>> {
        return Distillate { try self.option() }
    }
}
