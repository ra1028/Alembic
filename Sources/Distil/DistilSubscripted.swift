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
}

// MARK: - distil value functions

public extension DistilSubscripted {
    func to<T: Distillable>(_: T.Type) throws -> T {
        return try JSON(process()).distil()
    }
    
    func distil<T: Distillable>(_: T.Type = T.self) throws -> T {
        return try to(T)
    }
    
    func distil<T: Distillable>(_: T.Type = T.self) -> DistilBox<T> {
        return DistilBox {
            try self.distil()
        }
    }
}

// MARK: - distil array functions

public extension DistilSubscripted {
    func to<T: Distillable>(_: [T].Type) throws -> [T] {
        return try JSON(process()).distil()
    }
    
    func distil<T: Distillable>(_: [T].Type = [T].self) throws -> [T] {
        return try to([T])
    }
    
    func distil<T: Distillable>(_: [T].Type = [T].self) -> DistilBox<[T]> {
        return DistilBox {
            try self.distil()
        }
    }
}

// MARK: - distil dictionary functions

public extension DistilSubscripted {
    func to<T: Distillable>(_: [String: T].Type) throws -> [String: T] {
        return try JSON(process()).distil()
    }
    
    func distil<T: Distillable>(_: [String: T].Type = [String: T].self) throws -> [String: T] {
        return try to([String: T])
    }
    
    func distil<T: Distillable>(_: [String: T].Type = [String: T].self) -> DistilBox<[String: T]> {
        return DistilBox {
            try self.distil()
        }
    }
}