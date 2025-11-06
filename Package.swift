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
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/Macros",
            swiftSettings: .`default`
        ),
        .target(
            name: "Equatable",
            dependencies: [
                .target(name: "EquatableMacros")
            ],
            path: "Sources/Equatable",
            swiftSettings: .`default`
        ),
        .executableTarget(
            name: "EquatablePlaygound",
            dependencies: [
                "Equatable"
            ],
            path: "Sources/Playground",
            swiftSettings: .`default`
        )
    ]
)

// MARK: - SwiftSetting
private extension SwiftSetting {
    static let disableReflectionMetadata = SwiftSetting.unsafeFlags(["-Xfrontend", "-disable-reflection-metadata"], .when(configuration: .release))
    static let internalizeAtLink = SwiftSetting.unsafeFlags(["-Xfrontend", "-internalize-at-link"], .when(configuration: .release))
    static let approachableConcurrency = SwiftSetting.enableUpcomingFeature("ApproachableConcurrency")
    static let existentialAny = SwiftSetting.enableUpcomingFeature("ExistentialAny")
    static let internalImportsByDefault = SwiftSetting.enableUpcomingFeature("InternalImportsByDefault")
    static let memberImportVisibility = SwiftSetting.enableUpcomingFeature("MemberImportVisibility")
}

// MARK: - SwiftSetting
private extension Array<SwiftSetting> {
    static let `default`: Self = [
        .disableReflectionMetadata,
        .internalizeAtLink,
        .approachableConcurrency,
        .existentialAny,
        .internalImportsByDefault,
        .memberImportVisibility,
        .strictMemorySafety()
    ]
}
