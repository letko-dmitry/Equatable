//
//  Equatable.swift
//  Equatable
//
//  Created by Dzmitry Letko on 29/09/2026.
//

#if canImport(EquatableMacros)
import EquatableMacros
import SwiftSyntax
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import SwiftSyntaxMacrosTestSupport
import XCTest

final class EquatableTests: XCTestCase {
    func testStoredProperties() {
        assertMacroExpansion(
            """
            @Equatable
            public final class Model {
                static let shared = 0
                let a, b: Int
                var c = 0 {
                    didSet {}
                }
                lazy var d = 0
                var e: Int {
                    a
                }
            }
            """,
            expandedSource: """
            public final class Model {
                static let shared = 0
                let a, b: Int
                var c = 0 {
                    didSet {}
                }
                lazy var d = 0
                var e: Int {
                    a
                }
            }

            extension Model: Equatable {
                public static func == (lhs: Model, rhs: Model) -> Bool {
                    if lhs === rhs {
                        return true
                    }

                    return lhs.a == rhs.a &&
                    lhs.b == rhs.b &&
                    lhs.c == rhs.c &&
                    lhs.d == rhs.d
                }
            }
            """,
            macroSpecs: newConformance
        )
    }

    func testActor() {
        assertMacroExpansion(
            """
            @Equatable
            actor Session {
                let id: Int
                nonisolated(unsafe) var cache = 0
            }
            """,
            expandedSource: """
            actor Session {
                let id: Int
                nonisolated(unsafe) var cache = 0
            }

            extension Session: Equatable {
                static func == (lhs: Session, rhs: Session) -> Bool {
                    if lhs === rhs {
                        return true
                    }

                    return lhs.id == rhs.id &&
                    lhs.cache == rhs.cache
                }
            }
            """,
            macroSpecs: newConformance
        )
    }

    func testDeclaredConformance() {
        assertMacroExpansion(
            """
            @Equatable
            final class Model: Equatable {
            }
            """,
            expandedSource: """
            final class Model: Equatable {
            }

            extension Model {
                static func == (lhs: Model, rhs: Model) -> Bool {
                    lhs === rhs
                }
            }
            """,
            macroSpecs: existingConformance
        )
    }

    func testInheritedConformance() {
        assertMacroExpansion(
            """
            @Equatable
            final class Model: NSObject {
            }
            """,
            expandedSource: """
            final class Model: NSObject {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "`Model` conforms to `Equatable` through a superclass or an extension; `@Equatable` only implements `==` for `Equatable` declared on the type itself", line: 1, column: 1)
            ],
            macroSpecs: existingConformance
        )
    }

    func testNonFinalClass() {
        assertMacroExpansion(
            """
            @Equatable
            class Model {
            }
            """,
            expandedSource: """
            class Model {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "`@Equatable` can only be applied to a final class, since `==` inherited by a subclass would ignore the subclass's properties",
                    line: 2,
                    column: 1,
                    fixIts: [
                        FixItSpec(message: "Add `final`")
                    ]
                )
            ],
            macroSpecs: newConformance,
            fixedSource: """
            @Equatable
            final class Model {
            }
            """
        )
    }

    func testStruct() {
        assertMacroExpansion(
            """
            @Equatable
            struct Model {
            }
            """,
            expandedSource: """
            struct Model {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "`@Equatable` can only be applied to a final class or an actor; structs and enums get a synthesized `==` by conforming to `Equatable`", line: 1, column: 1)
            ],
            macroSpecs: newConformance
        )
    }

    func testActorVar() {
        assertMacroExpansion(
            """
            @Equatable
            actor Counter {
                var count = 0
            }
            """,
            expandedSource: """
            actor Counter {
                var count = 0
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "Actor-isolated `var count` can't be read by the nonisolated `==`; declare it with `let`", line: 3, column: 5)
            ],
            macroSpecs: newConformance
        )
    }
}

// MARK: - private
/// The compiler passes `Equatable` unless the type lists it, inherits it from a superclass, or gets it from an extension.
private let newConformance = ["Equatable": MacroSpec(type: EquatableMacros.Equatable.self, conformances: [TypeSyntax(IdentifierTypeSyntax(name: .identifier("Equatable")))])]
private let existingConformance = ["Equatable": MacroSpec(type: EquatableMacros.Equatable.self)]
#endif
