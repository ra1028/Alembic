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
    case Serialize
    
    var fileName: String {
        switch self {
        case .Distil: return "DistilTests"
        case .Optional: return "OptionalTests"
        case .Transform: return "TransformTests"
        case .Serialize: return "SerializeTests"
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
        return try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
    }
    
    func data(rootKey: String) -> NSData {
        return try! NSJSONSerialization.dataWithJSONObject(object(rootKey), options: [])
    }
    
    func string(rootKey: String) -> String {
        return String(data: data(rootKey), encoding: NSUTF8StringEncoding)!
    }
    
    func object(rootKey: String) -> AnyObject {
        return (object as! [String: AnyObject])[rootKey]!
    }
}