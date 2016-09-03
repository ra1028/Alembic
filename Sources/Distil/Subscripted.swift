//
//  Subscripted.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/29/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public final class Subscripted {
    fileprivate let j: JSON
    fileprivate let path: Path
    
    public subscript(path: PathElement) -> Subscripted {
        return .init(j, self.path + Path(path))
    }
    
    public subscript(path: PathElement...) -> Subscripted {
        return .init(j, self.path + Path(path))
    }
    
    init(_ j: JSON, _ path: Path) {
        self.j = j
        self.path = path
    }    
}

// MARK: - JSONType

extension Subscripted: JSONType {}

public extension Subscripted {
    func distil<T: Distillable>(to: T.Type = T.self) throws -> T {
        return try j.distil(path)
    }
    
    func distil<T: Distillable>(to: [T].Type = [T].self) throws -> [T] {
        return try j.distil(path)
    }
    
    func distil<T: Distillable>(to: [String: T].Type = [String: T].self) throws -> [String: T] {
        return try j.distil(path)
    }
}

public extension Subscripted {
    func option<T: Distillable>(to: T?.Type = (T?).self) throws -> T? {
        return try j.option(path)
    }
    
    func option<T: Distillable>(to: [T]?.Type = ([T]?).self) throws -> [T]? {
        return try j.option(path)
    }
    
    func option<T: Distillable>(to: [String: T]?.Type = ([String: T]?).self) throws -> [String: T]? {
        return try j.option(path)
    }
}
