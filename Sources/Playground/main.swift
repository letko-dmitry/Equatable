//
//  main.swift
//  Equatable
//
//  Created by Dzmitry Letko on 17/02/2025.
//

import Equatable

@Equatable
final class Object<Value: Equatable> {
    let value: Value
    
    init(value: Value) {
        self.value = value
    }
}

let object1 = Object(value: 123)
let objeect2 = Object(value: 123)
let objeect3 = Object(value: 234)

print("Equals: \(object1 == objeect2)")
print("Equals: \(object1 == object1)")
print("Not equals: \(object1 == objeect3)")
