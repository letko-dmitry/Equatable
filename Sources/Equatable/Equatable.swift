//
//  Macros.swift
//  Equatable
//
//  Created by Dzmitry Letko on 17/02/2025.
//

@attached(extension, conformances: Equatable, names: named(==))
public macro Equatable() = #externalMacro(module: "EquatableMacros", type: "Equatable")
