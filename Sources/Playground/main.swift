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

@Equatable
final class Object2<Value: Equatable> {
    let value1: Value
    let value2: Value
    let value3: Value
    
    init(value1: Value, value2: Value, value3: Value) {
        self.value1 = value1
        self.value2 = value2
        self.value3 = value3
    }
}

@Equatable
public final class Object3<Value: Equatable> {
    let value: Value
    
    init(value: Value) {
        self.value = value
    }
}

@Equatable
package final class Object4<Value: Equatable> {
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
