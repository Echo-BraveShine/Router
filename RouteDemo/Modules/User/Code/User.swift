//
//  User.swift
//  User
//
//  Created by Ekko on 2023/8/7.
//

import Foundation

struct User {
    var name: String = ""
    var age: UInt = 10
    var height: Float = 178
    var weight: Float = 68
    
    func toJSON() -> [String : Any] {
        return ["name": name,
                "age": age,
                "height":height,
                "weight":weight]
    }
}
