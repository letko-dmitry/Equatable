// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Equatable",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
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
        .package(url: "git@github.com:apple/swift-syntax.git", from: "600.0.1")
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
