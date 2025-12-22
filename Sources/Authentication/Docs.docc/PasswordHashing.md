# Password Hashing

Securely hash and verify user passwords using the bcrypt algorithm.

## Overview

The Authentication library provides a robust password hashing system built on the OpenBSD bcrypt algorithm. Bcrypt is specifically designed for password hashing and includes features like:

- **Adaptive cost factor**: Increase computational cost as hardware improves
- **Built-in salting**: Each hash includes a unique random salt
- **Timing-safe comparison**: Prevents timing attacks during verification

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

### Configuring Cost

The cost parameter controls how computationally expensive the hashing operation is. Higher costs provide more security but take longer to compute. The default cost of 12 is suitable for most applications.

```swift
// Create a hasher with custom cost (valid range: 4-31)
let hasher = BcryptHasher(cost: 14)

let hash = try hasher.hash("myPassword")
```

> Important: Increasing the cost by 1 doubles the computation time. A cost of 12 takes approximately 250ms on modern hardware. Choose a cost that provides adequate security while maintaining acceptable response times for your users.

### Low-Level API

For more control, you can use the ``VaporBcrypt`` type directly:

```swift
import Authentication

// Hash with explicit cost
let hash = try VaporBcrypt.hash("password", cost: 12)

// Verify password
let isValid = try VaporBcrypt.verify("password", created: hash)
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
