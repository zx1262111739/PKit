//
//  JSONTests.swift
//  
//
//  Created by Plumk on 2022/5/25.
//

import XCTest
@testable import PKCore
@testable import PKJSON


struct Job: PKJson {
    
    @JsonKey var name = ""
    @JsonKey var salary: Double = 0 {
        didSet {
            PKLog.log("new value")
        }
    }
}

class Person: NSObject, PKJson {
    
    @JsonKey @objc dynamic var name = ""
    @JsonKey
    var date = Date()
    
    @JsonKey var job = Job()
    
    required override init() {
        super.init()
    }
}




final class JSONTests: XCTestCase {
    
    func testDecode() throws {
        
        let json = """
{
    "name": "张三",
    "date": 1687690398,
    "job": {
        "name": "工人",
        "salary": "10000.5"
    }
}
"""
        
        let person = Person.decode(json)
        print(person.toJson())
    }
}
