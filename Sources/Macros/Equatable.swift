//
//  Equatable.swift
//  Equatable
//
//  Created by Dzmitry Letko on 17/02/2025.
//

public import SwiftSyntax
public import SwiftSyntaxMacros

import SwiftDiagnostics
import SwiftSyntaxBuilder

public enum Equatable: ExtensionMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        if let classDecl = declaration.as(ClassDeclSyntax.self), !classDecl.modifiers.contains(.final) {
            let message = MacroExpansionErrorMessage("`@Equatable` can only be applied to a final class, since `==` inherited by a subclass would ignore the subclass's properties")
            let fixIts = classDecl.modifiers.contains(.open) ? [] : [finalFixIt(for: classDecl)]

            context.diagnose(Diagnostic(node: classDecl.classKeyword, message: message, fixIts: fixIts))

            return []
        }

        guard declaration.is(ClassDeclSyntax.self) || declaration.is(ActorDeclSyntax.self) else {
            let message = MacroExpansionErrorMessage("`@Equatable` can only be applied to a final class or an actor; structs and enums get a synthesized `==` by conforming to `Equatable`")

            context.diagnose(Diagnostic(node: node, message: message))

            return []
        }

        let type = type.trimmed

        // The compiler leaves `Equatable` out of `protocols` when the type lists it, inherits it from a superclass, or gets it from an extension.
        guard !protocols.isEmpty || declaration.inheritanceClause?.inheritedTypes.contains(where: \.isEquatable) == true else {
            let message = MacroExpansionErrorMessage("`\(type)` conforms to `Equatable` through a superclass or an extension; `@Equatable` only implements `==` for `Equatable` declared on the type itself")

            context.diagnose(Diagnostic(node: node, message: message))

            return []
        }

        let variables = declaration.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter { !$0.modifiers.contains(.static, .class) && $0.bindings.contains(where: \.isStored) }

        let modifierKeywords: [TokenKind: TokenKind] = [
            .keyword(.public): .keyword(.public),
            .keyword(.package): .keyword(.package),
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

        return try [
            ExtensionDeclSyntax("extension \(type)\(raw: protocols.isEmpty ? "" : ": Equatable")") {
                try FunctionDeclSyntax("\(modifiers)static func == (lhs: \(type), rhs: \(type)) -> Bool") {
                    let properties = variables
                        .flatMap(\.bindings)
                        .filter(\.isStored)
                        .compactMap { $0.pattern.as(IdentifierPatternSyntax.self) }
                        .map { $0.identifier.text }
                    
                    if let first = properties.first {
                        "if lhs === rhs { return true }\n\n"
                        
                        if let last = properties.dropFirst().last {
                            "return lhs.\(raw: first) == rhs.\(raw: first) &&"
                            
                            for property in properties.dropFirst().dropLast() {
                                "lhs.\(raw: property) == rhs.\(raw: property) &&"
                            }
                            
                            "lhs.\(raw: last) == rhs.\(raw: last)"
                        } else {
                            "return lhs.\(raw: first) == rhs.\(raw: first)"
                        }
                    } else {
                        "lhs === rhs"
                    }
                }
            }
        ]

    }
}

// MARK: - private
private extension Equatable {
    static func finalFixIt(for classDecl: ClassDeclSyntax) -> FixIt {
        var finalClassDecl = classDecl
        finalClassDecl.modifiers.append(DeclModifierSyntax(name: .keyword(.final, leadingTrivia: classDecl.classKeyword.leadingTrivia, trailingTrivia: .space)))
        finalClassDecl.classKeyword.leadingTrivia = []

        return FixIt(message: MacroExpansionFixItMessage("Add `final`"), changes: [.replace(oldNode: Syntax(classDecl), newNode: Syntax(finalClassDecl))])
    }
}

// MARK: - private
private extension DeclModifierListSyntax {
    func contains(_ keywords: Keyword...) -> Bool {
        contains { modifier in
            keywords.contains { modifier.name.tokenKind == .keyword($0) }
        }
    }
}

// MARK: - private
private extension PatternBindingSyntax {
    /// A stored property has no accessors or only `willSet`/`didSet` observers.
    var isStored: Bool {
        switch accessorBlock?.accessors {
        case nil: true
        case .getter: false
        case .accessors(let accessors): accessors.allSatisfy { [.keyword(.willSet), .keyword(.didSet)].contains($0.accessorSpecifier.tokenKind) }
        }
    }
}

// MARK: - private
private extension InheritedTypeSyntax {
    var isEquatable: Bool {
        ["Equatable", "Swift.Equatable"].contains(type.trimmedDescription)
    }
}

