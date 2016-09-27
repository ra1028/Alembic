//
//  LazyJSON.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/29/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

public final class LazyJSON {
    fileprivate let json: JSON
    public let currentPath: Path
    
    public subscript(path: PathElement) -> LazyJSON {
        return .init(json, currentPath + Path(path))
    }
    
    public subscript(path: PathElement...) -> LazyJSON {
        return .init(json, currentPath + Path(path))
    }
    
    init(_ json: JSON, _ path: Path) {
        self.json = json
        currentPath = path
    }    
}

// MARK: - JSONType

extension LazyJSON: JSONType {
    public func asJSON() -> JSON {
        return json
    }
}
