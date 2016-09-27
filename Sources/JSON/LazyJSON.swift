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
    
    public subscript(element: PathElement) -> LazyJSON {
        return .init(json: json, path: currentPath + .init(element: element))
    }
    
    public subscript(element: PathElement...) -> LazyJSON {
        return .init(json: json, path: currentPath + .init(elements: element))
    }
    
    init(json: JSON, path: Path) {
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
