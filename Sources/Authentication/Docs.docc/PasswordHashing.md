# Password Hashing

Securely hash and verify user passwords using the bcrypt algorithm.

## Overview

The Authentication library provides a robust password hashing system built on the OpenBSD bcrypt algorithm. Bcrypt is specifically designed for password hashing and includes features like:

- **Adaptive cost factor**: Increase computational cost as hardware improves
- **Built-in salting**: Each hash includes a unique random salt
- **Timing-safe comparison**: Prevents timing attacks during verification

If you prefer, you can also use the PBKDF2 algorithm for password hashing by utilizing the `PBKDF2Hasher`. PBKDF2 is a general key derivation function that is widely used for securely hashing passwords. It is considered less secure than bcrypt against modern hardware attacks.

### Basic Usage

#### ``PasswordHasher``

The ``PasswordHasher`` protocol allows you to write agnostic code for hashing and verifying passwords, to make it easy to change for testing, for example:

```swift
// Where `hasher` is a `PasswordHasher` configured elsewhere
let hash = try hasher.hash("password")

let isValid = try hasher.verify("password", created: hash)
```

#### ``BcryptHasher``

Use ``BcryptHasher`` to hash and verify passwords directly:

```swift
import Authentication

// Create a hasher with default cost (12)
let hasher = BcryptHasher()

// Hash a password
let hash = try hasher.hash("secretPassword123")

// Verify a password against a hash
let isValid = try hasher.verify("secretPassword123", created: hash)
// isValid == true
```

#### ``PBKDF2Hasher``

Use ``PBKDF2Hasher`` to hash and verify passwords using the PBKDF2 algorithm:

```swift
import Authentication

// Create a PBKDF2 hasher with default settings (SHA256, 600,000 iterations)
let hasher = PBKDF2Hasher()

// Hash a password
let hash = try hasher.hash("secretPassword123")

// Verify a password against a hash
let isValid = try hasher.verify("secretPassword123", created: hash)
// isValid == true
```

### Configuration

#### Bcrypt

The cost parameter controls how computationally expensive the hashing operation is. Higher costs provide more security but take longer to compute. The default cost of 12 is suitable for most applications.

```swift
// Create a hasher with custom cost (valid range: 4-31)
let hasher = BcryptHasher(cost: 14)

let hash = try hasher.hash("myPassword")
```

> Important: Increasing the cost by 1 doubles the computation time. A cost of 12 takes approximately 250ms on modern hardware. Choose a cost that provides adequate security while maintaining acceptable response times for your users.

#### PBKDF2

In PBKDF2, you can configure the number of iterations and hashing function. There are sensible standards in place already depending on the hash algorithm used, so only adjust the iterations if necessary:

```swift
// Create a PBKDF2 hasher with custom iterations
let hasher = PBKDF2Hasher(
    pseudoRandomFunction: .sha256,
    iterations: 600_000,
)
let hash = try hasher.hash("myPassword")
```

### Low-Level API

For more control, you can use the ``VaporBcrypt`` type directly:

```swift
import Authentication

// Hash with explicit cost
let hash = try VaporBcrypt.hash("password", cost: 12)

// Verify password
let isValid = try VaporBcrypt.verify("password", created: hash)
```

Or, for PBKDF2,:

```swift
import Authentication

// Hash with explicit parameters
let hash = try PBKDF2Hasher.hash(
    Array("password".utf8),
    pseudoRandomFunction: .sha256,
    iterations: 600_000
)

// Verify password
let isValid = try PBKDF2Hasher.verify(
    Array("password".utf8),
    created: hash
)
```

### Testing with PlaintextHasher

For testing purposes, you can use ``PlaintextHasher`` which stores passwords without hashing:

```swift
import Authentication

let hasher = PlaintextHasher()
let hash = try hasher.hash("password")
// hash == "password"
```

> Warning: Never use ``PlaintextHasher`` in production. It provides no security and should only be used in tests to avoid the time of using a real hasher.

## Topics

### Hashers

- ``PasswordHasher``
- ``BcryptHasher``
- ``PlaintextHasher``

### Low-Level API

- ``VaporBcrypt``

### Errors

- ``BcryptError``
