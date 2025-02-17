//
//  Equatable.swift
//  Equatable
//
//  Created by Dzmitry Letko on 17/02/2025.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum EquatableExtensionError: CustomStringConvertible, Error {
    case finalClassOrActor
    
    public var description: String {
        switch self {
        case .finalClassOrActor:
            "@Equatable can only be applied to final class or actor"
        }
    }
}

public enum Equatable: ExtensionMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard [.classDecl, .actorDecl].contains(declaration.kind) else {
            throw EquatableExtensionError.finalClassOrActor
        }
        
        if case .classDecl = declaration.kind, !declaration.modifiers.contains(where: { $0.name.tokenKind == .keyword(.final) }) {
            throw EquatableExtensionError.finalClassOrActor
        }
        
        let modifierKeywords: [TokenKind: TokenKind] = [
            .keyword(.public): .keyword(.public),
            .keyword(.private): .keyword(.fileprivate),
            .keyword(.fileprivate): .keyword(.fileprivate)
        ]
        
        let modifiers = DeclModifierListSyntax {
            declaration.modifiers.compactMap { modifier in
                modifierKeywords[modifier.name.tokenKind].map { tokenKind in
                    DeclModifierSyntax(name: TokenSyntax(tokenKind, leadingTrivia: .newline, trailingTrivia: .space, presence: .present))
                }
            }
        }
        
        let type = type.trimmed
        
        return try [
            ExtensionDeclSyntax("extension \(type): Equatable") {
                try FunctionDeclSyntax("\(modifiers)static func == (lhs: \(type), rhs: \(type)) -> Bool") {
                    let properties = declaration.memberBlock.members
                        .compactMap { $0.decl.as(VariableDeclSyntax.self) }
                        .compactMap { $0.bindings.first }
                        .filter { $0.accessorBlock == nil }
                        .compactMap { $0.pattern.as(IdentifierPatternSyntax.self) }
                        .map { $0.identifier.text }
                    
                    if let last = properties.last {
                        "lhs === rhs ||"
                        
                        for property in properties.dropLast() {
                            "lhs.\(raw: property) == rhs.\(raw: property) &&"
                        }
                        
                        "lhs.\(raw: last) == rhs.\(raw: last)"
                    } else {
                        "lhs === rhs"
                    }
                }
            }
        ]

    }
}

