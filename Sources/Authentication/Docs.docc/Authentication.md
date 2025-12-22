# ``Authentication``

A lightweight authentication library for Swift providing common authentication operations, such as password hashing and OTP verification and generation.

## Overview

The Authentication library is a framework independent library for authentication for server-side Swift. It currently implementations for:

- **Password Hashing**: Securely hash and verify passwords using the bcrypt algorithm
- **One-Time Passwords**: Generate HOTP (counter-based) and TOTP (time-based) codes for multi-factor authentication

### Requirements

- Swift 6.2.3+
- Apple OS 26+ or any other supported Swift platform

### Installation

Add the Authentication package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/vapor/authentication.git", from: "3.0.0-beta")
]
```

Then add `Authentication` to your target's dependencies:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "Authentication", package: "authentication")
        ]
    )
]
```

## Topics

### Essentials

- <doc:PasswordHashing>
- <doc:OneTimePasswords>

### Password Hashing

- ``PasswordHasher``
- ``BcryptHasher``
- ``PlaintextHasher``
- ``BcryptError``

### One-Time Passwords

- ``HOTP``
- ``TOTP``
- ``OTPDigits``
- ``OTPDigest``
