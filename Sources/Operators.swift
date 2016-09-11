//
//  Operators.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/25/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

precedencegroup DistillingPrecendence {
    associativity: left
    higherThan: MultiplicationPrecedence
}

infix operator <| : DistillingPrecendence
infix operator <|? : DistillingPrecendence

// MARK: - distil value functions

public extension JSON {
    static func <| <T: Distillable>(j: JSON, path: Path) throws -> T {
        return try j.distil(path)
    }
    
    static func <| <T: Distillable>(j: JSON, path: Path) -> (T.Type) throws -> T {
        return { _ in try j <| path }
    }
    
    static func <| <T: Distillable>(j: JSON, path: Path) -> InsecureDistillate<T> {
        return .init { try j <| path }
    }
    
    static func <| <T: Distillable>(j: JSON, path: Path) -> (T.Type) -> InsecureDistillate<T> {
        return  { _ in .init { try j <| path } }
    }
}

// MARK: - distil option value functions

public extension JSON {
    static func <|? <T: Distillable>(j: JSON, path: Path) throws -> T? {
        return try j.option(path)
    }
    
    static func <|? <T: Distillable>(j: JSON, path: Path) -> (T?.Type) throws -> T? {
        return { _ in try j <|? path }
    }
    
    static func <|? <T: Distillable>(j: JSON, path: Path) -> InsecureDistillate<T?> {
        return .init { try j <|? path }
    }
    
    static func <|? <T: Distillable>(j: JSON, path: Path) -> (T?.Type) -> InsecureDistillate<T?> {
        return  { _ in .init { try j <|? path } }
    }
}

// MARK: - distil array functions

public extension JSON {
    static func <| <T: Distillable>(j: JSON, path: Path) throws -> [T] {
        return try j.distil(path)
    }
    
    static func <| <T: Distillable>(j: JSON, path: Path) -> ([T].Type) throws -> [T] {
        return { _ in try j <| path }
    }
    
    static func <| <T: Distillable>(j: JSON, path: Path) -> InsecureDistillate<[T]> {
        return .init { try j <| path }
    }
    
    static func <| <T: Distillable>(j: JSON, path: Path) -> ([T].Type) -> InsecureDistillate<[T]> {
        return  { _ in .init { try j <| path } }
    }
}

// MARK: - distil option array functions

public extension JSON {
    static func <|? <T: Distillable>(j: JSON, path: Path) throws -> [T]? {
        return try j.option(path)
    }
    
    static func <|? <T: Distillable>(j: JSON, path: Path) -> ([T]?.Type) throws -> [T]? {
        return { _ in try j <|? path }
    }
    
    static func <|? <T: Distillable>(j: JSON, path: Path) -> InsecureDistillate<[T]?> {
        return .init { try j <|? path }
    }
    
    static func <|? <T: Distillable>(j: JSON, path: Path) -> ([T]?.Type) -> InsecureDistillate<[T]?> {
        return  { _ in .init { try j <|? path } }
    }
}

// MARK: - distil dictionary functions
    
public extension JSON {
    static func <| <T: Distillable>(j: JSON, path: Path) throws -> [String: T] {
        return try j.distil(path)
    }
    
    static func <| <T: Distillable>(j: JSON, path: Path) -> ([String: T].Type) throws -> [String: T] {
        return { _ in try j <| path }
    }
    
    static func <| <T: Distillable>(j: JSON, path: Path) -> InsecureDistillate<[String: T]> {
        return .init { try j <| path }
    }
    
    static func <| <T: Distillable>(j: JSON, path: Path) -> ([String: T].Type) -> InsecureDistillate<[String: T]> {
        return  { _ in .init { try j <| path } }
    }
}

// MARK: - distil option dictionary functions

public extension JSON {
    static func <|? <T: Distillable>(j: JSON, path: Path) throws -> [String: T]? {
        return try j.option(path)
    }
    
    static func <|? <T: Distillable>(j: JSON, path: Path) -> ([String: T]?.Type) throws -> [String: T]? {
        return { _ in try j <|? path }
    }
    
    static func <|? <T: Distillable>(j: JSON, path: Path) -> InsecureDistillate<[String: T]?> {
        return .init { try j <|? path }
    }
    
    static func <|? <T: Distillable>(j: JSON, path: Path) -> ([String: T]?.Type) -> InsecureDistillate<[String: T]?> {
        return  { _ in .init { try j <|? path } }
    }
}
