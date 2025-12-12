// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "auth",
    products: [
        .library(name: "Authentication", targets: ["Authentication"]),
    ],
    dependencies: [
        // 🔑 Hashing (BCrypt, SHA, HMAC, etc), encryption, and randomness.
        .package(url: "https://github.com/apple/swift-crypto.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "Authentication",
            dependencies: [
                .product(name: "CryptoExtras", package: "swift-crypto"),
            ]
        ),
        .testTarget(name: "AuthenticationTests", dependencies: ["Authentication"]),
    ]
)
