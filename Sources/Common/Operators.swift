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

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> (T.Type) throws -> T {
    return { _ in try j <| path }
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> InsecureDistillate<T> {
    return InsecureDistillate { try j <| path }
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> (T.Type) -> InsecureDistillate<T> {
    return  { _ in InsecureDistillate { try j <| path } }
}

// MARK: - distil option value functions

public func <|? <T: Distillable>(j: JSON, path: JSONPath) throws -> Optional<T> {
    return try j.option(path)
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> (Optional<T>.Type) throws -> Optional<T> {
    return { _ in try j <|? path }
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> InsecureDistillate<Optional<T>> {
    return InsecureDistillate { try j <|? path }
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> (Optional<T>.Type) -> InsecureDistillate<Optional<T>> {
    return  { _ in InsecureDistillate { try j <|? path } }
}

// MARK: - distil array functions

public func <| <T: Distillable>(j: JSON, path: JSONPath) throws -> [T] {
    return try j.distil(path)
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> ([T].Type) throws -> [T] {
    return { _ in try j <| path }
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> InsecureDistillate<[T]> {
    return InsecureDistillate { try j <| path }
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> ([T].Type) -> InsecureDistillate<[T]> {
    return  { _ in InsecureDistillate { try j <| path } }
}

// MARK: - distil option array functions

public func <|? <T: Distillable>(j: JSON, path: JSONPath) throws -> Optional<[T]> {
    return try j.option(path)
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> (Optional<[T]>.Type) throws -> Optional<[T]> {
    return { _ in try j <|? path }
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> InsecureDistillate<Optional<[T]>> {
    return InsecureDistillate { try j <|? path }
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> (Optional<[T]>.Type) -> InsecureDistillate<Optional<[T]>> {
    return  { _ in InsecureDistillate { try j <|? path } }
}

// MARK: - distil dictionary functions

public func <| <T: Distillable>(j: JSON, path: JSONPath) throws -> [String: T] {
    return try j.distil(path)
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> ([String: T].Type) throws -> [String: T] {
    return { _ in try j <| path }
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> InsecureDistillate<[String: T]> {
    return InsecureDistillate { try j <| path }
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> ([String: T].Type) -> InsecureDistillate<[String: T]> {
    return  { _ in InsecureDistillate { try j <| path } }
}

// MARK: - distil option dictionary functions

public func <|? <T: Distillable>(j: JSON, path: JSONPath) throws -> Optional<[String: T]> {
    return try j.option(path)
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> (Optional<[String: T]>.Type) throws -> Optional<[String: T]> {
    return { _ in try j <|? path }
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> InsecureDistillate<Optional<[String: T]>> {
    return InsecureDistillate { try j <|? path }
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> (Optional<[String: T]>.Type) -> InsecureDistillate<Optional<[String: T]>> {
    return  { _ in InsecureDistillate { try j <|? path } }
}
