//
//  Plugin.swift
//  Equatable
//
//  Created by Dzmitry Letko on 17/02/2025.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct Plugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Equatable.self,
    ]
}
