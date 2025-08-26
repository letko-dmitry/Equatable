// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Equatable",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "Equatable",
            targets: [
                "Equatable"
            ]
        )
    ],
    dependencies: [
        .package(url: "git@github.com:swiftlang/swift-syntax.git", from: "601.0.1")
    ],
    targets: [
        .macro(
            name: "EquatableMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/Macros"
        ),
        .target(
            name: "Equatable",
            dependencies: [
                .target(name: "EquatableMacros")
            ],
            path: "Sources/Equatable"
        ),
        .executableTarget(
            name: "EquatablePlaygound",
            dependencies: [
                "Equatable"
            ],
            path: "Sources/Playground"
        )
    ]
)
