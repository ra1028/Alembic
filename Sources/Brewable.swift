//
//  Brewable.swift
//  Alembic
//
//  Created by Ryo Aoyama on 9/11/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

public protocol Brewable: Distillable {
    init(json j: JSON) throws
}

public extension Brewable {
    static func distil(json j: JSON) throws -> Self {
        return try .init(json: j)
    }
}
