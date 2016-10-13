//
//  Distillate+Creation.swift
//  Alembic
//
//  Created by Ryo Aoyama on 2016/09/04.
//  Copyright © 2016年 Ryo Aoyama. All rights reserved.
//

public extension Distillate {
    static func filter() -> InsecureDistillate<Value> {
        return error(DistillError.filteredValue(type: Value.self, value: ()))
    }
    
    static func error(_ error: Error) -> InsecureDistillate<Value> {
        return .init { throw error }
    }
    
    static func just(_ element: @autoclosure @escaping () -> Value) -> SecureDistillate<Value> {
        return .init(element)
    }
}
