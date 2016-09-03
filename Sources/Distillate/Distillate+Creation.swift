//
//  Distillate+Creation.swift
//  Alembic
//
//  Created by 青山 遼 on 2016/09/04.
//  Copyright © 2016年 Ryo Aoyama. All rights reserved.
//

import Foundation

public extension Distillate {
    static var filter: InsecureDistillate<Value> {
        return error(DistillError.filteredValue(type: Value.self, value: ()))
    }
    
    static func error(_ error: Error) -> InsecureDistillate<Value> {
        return .init { throw error }
    }
    
    static func just(_ element: @autoclosure @escaping () -> Value) -> SecureDistillate<Value> {
        return .init(element)
    }
}
