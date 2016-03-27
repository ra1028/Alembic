//
//  TestJSON.swift
//  Tests
//
//  Created by Ryo Aoyama on 3/26/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

enum TestJSON {
    case Distil
    case Optional
    case Transform
    
    var fileName: String {
        switch self {
        case .Distil: return "DistilTests"
        case .Optional: return "OptionalTests"
        case .Transform: return "TransformTests"
        }
    }
    
    var data: NSData {
        return NSBundle(forClass: DistilTests.self).pathForResource(fileName, ofType: "json")
            .flatMap(NSData.init(contentsOfFile:))!
    }
    
    var string: String {
        return String(data: data, encoding: NSUTF8StringEncoding)!
    }
    
    var object: AnyObject {
        return try! NSJSONSerialization.JSONObjectWithData(data, options: [])
    }
}