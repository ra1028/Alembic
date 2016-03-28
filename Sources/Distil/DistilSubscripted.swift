//
//  DistilSubscripted.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/29/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public struct DistilSubscripted {
    private let process: () throws -> AnyObject
    
    init(process: () throws -> AnyObject) {
        self.process = process
    }
    
    public subscript(path: JSONPathElement) -> DistilSubscripted {
        return DistilSubscripted {
            return try JSON(self.process()).distil(JSONPath(path))(JSON).raw
        }
    }
}

// MARK: - distil value functions

public extension DistilSubscripted {
    func to<T: Distillable>(_: T.Type) throws -> T {
        let object = try process()
        guard let value = object as? T else {
            throw DistilError.TypeMismatch(expected: T.self, actual: object)
        }
        return value
    }
    
    func toResult<T: Distillable>(_: T.Type = T.self) -> DistilResult<T> {
        return DistilResult {
            return try self.to(T)
        }
    }
}

// MARK: - distil array functions

public extension DistilSubscripted {
    public func to<T: Distillable>(_: [T].Type) throws -> [T] {
        let object = try process()
        guard let value = object as? [T] else {
            throw DistilError.TypeMismatch(expected: [T].self, actual: object)
        }
        return value
    }
    
    public func toResult<T: Distillable>(_: [T].Type = [T].self) -> DistilResult<[T]> {
        return DistilResult {
            return try self.to([T])
        }
    }
}

// MARK: - distil dictionary functions

public extension DistilSubscripted {
    func to<T: Distillable>(_: [String: T].Type) throws -> [String: T] {
        let object = try process()
        guard let value = object as? [String: T] else {
            throw DistilError.TypeMismatch(expected: [String: T].self, actual: object)
        }
        return value
    }
    
    func toResult<T: Distillable>(_: [String: T].Type = [String: T].self) -> DistilResult<[String: T]> {
        return DistilResult {
            return try self.to([String: T])
        }
    }
}