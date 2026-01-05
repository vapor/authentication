// swift-tools-version:6.2
// This should really be 6.2.3, but Xcode yet again has a bug
import PackageDescription

let extraSettings: [SwiftSetting] = [
    .enableExperimentalFeature("SuppressedAssociatedTypes"),
    .enableExperimentalFeature("LifetimeDependence"),
    .enableUpcomingFeature("LifetimeDependence"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    //    .treatAllWarnings(as: .error),
    .strictMemorySafety(),
    .enableExperimentalFeature("SafeInteropWrappers"),
    .unsafeFlags(["-Xcc", "-fexperimental-bounds-safety-attributes"]),
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
        .trait(name: "PBKDF2",),
        .default(enabledTraits: [
            "bcrypt",
            "OTP",
        ]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "CVaporAuthBcrypt",
            cSettings: [
                .define("ENABLE_C_BOUNDS_SAFETY")
            ],
            swiftSettings: extraSettings,
        ),
        .target(
            name: "Authentication",
            dependencies: [
                .target(name: "CVaporAuthBcrypt", condition: .when(traits: ["bcrypt"])),
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
