<p align="center">
<img src="https://user-images.githubusercontent.com/1342803/36690387-2b24de90-1b00-11e8-8a8a-5cae6c96261b.png" height="96" alt="Vapor Authentication">
<br>
<br>
<a href="https://docs.vapor.codes/4.0/"><img src="https://design.vapor.codes/images/readthedocs.svg" alt="Documentation"></a>
<a href="https://discord.gg/vapor"><img src="https://design.vapor.codes/images/discordchat.svg" alt="Team Chat"></a>
<a href="LICENSE"><img src="https://design.vapor.codes/images/mitlicense.svg" alt="MIT License"></a>
<a href="https://github.com/vapor/authentication/actions/workflows/test.yml"><img src="https://img.shields.io/github/actions/workflow/status/vapor/authentication/test.yml?event=push&style=plastic&logo=github&label=tests&logoColor=%23ccc" alt="Continuous Integration"></a>
<a href="https://codecov.io/github/vapor/authentication"><img src="https://img.shields.io/codecov/c/github/vapor/authentication?style=plastic&logo=codecov&label=codecov" alt="Code Coverage"></a>
<a href="https://swift.org"><img src="https://design.vapor.codes/images/swift62up.svg" alt="Swift 6.2+"></a>
</p>

A lightweight authentication library for Swift providing common authentication operations, such as password hashing and OTP verification and generation.

## Installation

Add the Authentication package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/vapor/authentication.git", from: "4.0.0")
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

## Password Hashing

Securely hash and verify user passwords using the bcrypt algorithm or the `PasswordHasher` algorithm:

```swift
import Authentication

// Create a hasher with default cost (12)
let hasher = BcryptHasher()
// Or a hasher injected in
let hasher: PasswordHasher

// Hash a password
let hash = try hasher.hash("secretPassword123")

// Verify a password against a hash
let isValid = try hasher.verify("secretPassword123", created: hash)
// isValid == true
```

### Configuring Cost

The cost parameter controls how computationally expensive the hashing operation is. Higher costs provide more security but take longer to compute:

```swift
// Create a hasher with custom cost (valid range: 4-31)
let hasher = BcryptHasher(cost: 14)

let hash = try hasher.hash("myPassword")
```

> **Note**: Increasing the cost by 1 doubles the computation time. A cost of 12 takes approximately 250ms on modern hardware.

## One-Time Passwords (OTP)

Generate RFC-compliant HOTP and TOTP codes for multi-factor authentication.

### Time-Based One-Time Passwords (TOTP)

TOTP generates codes that change at regular intervals (typically 30 seconds):

```swift
import Authentication
import Crypto

// Create a symmetric key (store this securely per user)
let key = SymmetricKey(size: .bits256)

// Create a TOTP generator
let totp = TOTP(key: key, digest: .sha256)

// Generate a code for the current time
let code = totp.generate(time: Date())
print(code)  // e.g., "482719"
```

### Hash-Based One-Time Passwords (HOTP)

HOTP generates codes based on a counter value:

```swift
import Authentication
import Crypto

let key = SymmetricKey(size: .bits256)

// Create an HOTP generator
let hotp = HOTP(key: key, digest: .sha256)

// Generate codes for sequential counters
let code0 = hotp.generate(counter: 0)
let code1 = hotp.generate(counter: 1)
```

### Configuring OTP Parameters

Both HOTP and TOTP support configuration options:

```swift
// Configure digest algorithm: .sha1, .sha256, or .sha512
let totp = TOTP(key: key, digest: .sha512)

// Configure code length: .six, .seven, or .eight digits
let totp = TOTP(key: key, digest: .sha256, digits: .eight)

// Configure time interval (TOTP only, default: 30 seconds)
let totp = TOTP(key: key, digest: .sha256, interval: 60)
```

### Verifying Codes with Range Tolerance

To account for clock drift or user delays, generate multiple codes within a range:

```swift
let totp = TOTP(key: key, digest: .sha256)

// Generate codes for current time plus/minus 1 interval
let codes = totp.generate(time: Date(), range: 1)
// Returns 3 codes: [previous, current, next]

// Check if user's code matches any valid code
let isValid = codes.contains(userCode)
```