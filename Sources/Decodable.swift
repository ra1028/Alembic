//
//  Decodable.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/25/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public protocol Decodable: Distillable {
    init(j: JSON) throws
}

public extension Decodable {
    typealias DecodedType = Self
    
    static func distil(j: JSON) throws -> DecodedType {
        return try self.init(j: j)
    }
}