//
//  OptionalConvertible.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/13/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

public protocol OptionalConvertible {
    associatedtype Wrapped
    
    var optionalValue: Wrapped? { get }
}

extension Optional: OptionalConvertible {
    public var optionalValue: Wrapped? {
        return self
    }
}
