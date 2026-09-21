// swift-tools-version:6.4
import PackageDescription

let extraSettings: [SwiftSetting] = [
    .treatAllWarnings(as: .error),
    .strictMemorySafety(),
    .enableExperimentalFeature("LifetimeDependence"),
    .enableExperimentalFeature("SuppressedAssociatedTypesWithDefaults"),
    .enableExperimentalFeature("Lifetimes"),
    .enableExperimentalFeature("SafeInteropWrappers"),
    .enableUpcomingFeature("LifetimeDependence"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("ImmutableWeakCaptures"),
]

let package = Package(
    name: "authentication",
    platforms: [
        .macOS(.v26),
        .macCatalyst(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(name: "Authentication", targets: ["Authentication"])
    ],
    traits: [
        .trait(name: "bcrypt"),
        .trait(name: "OTP"),
        .trait(name: "PBKDF2"),
        .default(enabledTraits: [
            "bcrypt",
            "OTP",
        ]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "4.0.0"),
        .package(url: "https://github.com/ptoffy/bcrypt.git", .upToNextMinor(from: "0.5.0")),
    ],
    targets: [
        .target(
            name: "Authentication",
            dependencies: [
                .product(name: "Bcrypt", package: "bcrypt", condition: .when(traits: ["bcrypt"])),
                .product(name: "Crypto", package: "swift-crypto", condition: .when(traits: ["bcrypt", "OTP"])),
                .product(name: "CryptoExtras", package: "swift-crypto", condition: .when(traits: ["PBKDF2"])),
            ],
            swiftSettings: extraSettings
        ),
        .testTarget(
            name: "AuthenticationTests",
            dependencies: [
                "Authentication"
            ],
            swiftSettings: extraSettings
        ),
    ],
)
