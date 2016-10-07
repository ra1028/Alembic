//
//  LazyJSON.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/29/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

public final class LazyJSON {
    fileprivate let rootJSON: JSON
    fileprivate let currentPath: Path
    
    public subscript(element: PathElement...) -> LazyJSON {
        return .init(rootJSON: rootJSON, currentPath: currentPath + .init(elements: element))
    }
    
    init(rootJSON: JSON, currentPath: Path) {
        self.rootJSON = rootJSON
        self.currentPath = currentPath
    }
}

// MARK: - JSONType

extension LazyJSON: JSONType {
    public func distil<T: Distillable>(_ path: Path, as: T.Type) throws -> T {
        return try rootJSON.distil(currentPath + path)
    }
    
    public func option<T: Distillable>(_ path: Path, as: T?.Type) throws -> T? {
        return try rootJSON.option(currentPath + path)
    }
}

// MARK: - CustomStringConvertible

extension LazyJSON: CustomStringConvertible {
    public var description: String {
        return "LazyJSON(rootJSON: \(rootJSON), currentPath: \(currentPath))"
    }
}

// MARK: - CustomDebugStringConvertible

extension LazyJSON: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}
