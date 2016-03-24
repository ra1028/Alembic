//
//  Operators.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/25/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

infix operator <| { associativity left precedence 150 }
infix operator <|? { associativity left precedence 150 }

// MARK: - distil value functions

public func <| <T: Distillable>(j: JSON, path: JSONPath) throws -> T {
    return try j.distil(path)
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> T.Type throws -> T {
    return { _ in
        try j <| path
    }
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> DistilResult<T> {
    return DistilResult() {
        try j <| path
    }
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> T.Type -> DistilResult<T> {
    return  { _ in
        DistilResult() {
            try j <| path
        }
    }
}

// MARK: - distil optional value functions

public func <|? <T: Distillable>(j: JSON, path: JSONPath) throws -> Optional<T> {
    return try j.optional(path)
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> Optional<T>.Type throws -> Optional<T> {
    return { _ in
        try j <|? path
    }
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> DistilResult<Optional<T>> {
    return DistilResult() {
        try j <|? path
    }
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> Optional<T>.Type -> DistilResult<Optional<T>> {
    return  { _ in
        DistilResult() {
            try j <|? path
        }
    }
}

// MARK: - distil array functions

public func <| <T: Distillable>(j: JSON, path: JSONPath) throws -> [T] {
    return try j.distil(path)
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> [T].Type throws -> [T] {
    return { _ in
        try j <| path
    }
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> DistilResult<[T]> {
    return DistilResult() {
        try j <| path
    }
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> [T].Type -> DistilResult<[T]> {
    return  { _ in
        DistilResult() {
            try j <| path
        }
    }
}

// MARK: - distil optional array functions

public func <|? <T: Distillable>(j: JSON, path: JSONPath) throws -> Optional<[T]> {
    return try j.optional(path)
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> Optional<[T]>.Type throws -> Optional<[T]> {
    return { _ in
        try j <|? path
    }
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> DistilResult<Optional<[T]>> {
    return DistilResult() {
        try j <|? path
    }
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> Optional<[T]>.Type -> DistilResult<Optional<[T]>> {
    return  { _ in
        DistilResult() {
            try j <|? path
        }
    }
}

// MARK: - distil dictionary functions

public func <| <T: Distillable>(j: JSON, path: JSONPath) throws -> [String: T] {
    return try j.distil(path)
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> [String: T].Type throws -> [String: T] {
    return { _ in
        try j <| path
    }
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> DistilResult<[String: T]> {
    return DistilResult() {
        try j <| path
    }
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> [String: T].Type -> DistilResult<[String: T]> {
    return  { _ in
        DistilResult() {
            try j <| path
        }
    }
}

// MARK: - distil optional dictionary functions

public func <|? <T: Distillable>(j: JSON, path: JSONPath) throws -> Optional<[String: T]> {
    return try j.optional(path)
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> Optional<[String: T]>.Type throws -> Optional<[String: T]> {
    return { _ in
        try j <|? path
    }
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> DistilResult<Optional<[String: T]>> {
    return DistilResult() {
        try j <|? path
    }
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> Optional<[String: T]>.Type -> DistilResult<Optional<[String: T]>> {
    return  { _ in
        DistilResult() {
            try j <|? path
        }
    }
}
