# One-Time Passwords

Generate HOTP and TOTP codes for multi-factor authentication.

## Overview

The Authentication library provides RFC-compliant implementations of one-time password algorithms:

- **HOTP** (RFC 4226): Counter-based one-time passwords
- **TOTP** (RFC 6238): Time-based one-time passwords

These are commonly used for two-factor authentication (2FA) and are compatible with authenticator apps like Google Authenticator, Authy, and 1Password.

### Time-Based One-Time Passwords (TOTP)

TOTP generates codes that change at regular intervals (typically 30 seconds). This is the most common form of 2FA:

```swift
import Authentication
import Crypto

// Create a symmetric key (in practice, store this securely per user)
let key = SymmetricKey(size: .bits256)

// Create a TOTP generator
let totp = TOTP(key: key, digest: .sha256)

// Generate a code for the current time
let code = totp.generate(time: Date())
print(code)  // e.g., "482719"
```

### Hash-Based One-Time Passwords (HOTP)

HOTP generates codes based on a counter value that increments with each use:

```swift
import Authentication
import Crypto

let key = SymmetricKey(size: .bits256)

// Create an HOTP generator
let hotp = HOTP(key: key, digest: .sha256)

// Generate codes for sequential counters
let code0 = hotp.generate(counter: 0)  // First code
let code1 = hotp.generate(counter: 1)  // Second code
```

### Configuring OTP Parameters

Both HOTP and TOTP support configuration options:

#### Digest Algorithm

Choose the hash function used for HMAC calculation:

```swift
// SHA-1 (legacy, still widely supported)
let totp1 = TOTP(key: key, digest: .sha1)

// SHA-256 (recommended)
let totp2 = TOTP(key: key, digest: .sha256)

// SHA-512 (highest security)
let totp3 = TOTP(key: key, digest: .sha512)
```

#### Code Length

Configure the number of digits in the generated code:

```swift
// 6 digits (default, most common)
let totp6 = TOTP(key: key, digest: .sha256, digits: .six)

// 7 digits
let totp7 = TOTP(key: key, digest: .sha256, digits: .seven)

// 8 digits (higher security)
let totp8 = TOTP(key: key, digest: .sha256, digits: .eight)
```

#### Time Interval (TOTP only)

Configure how often codes change:

```swift
// 30 seconds (default, standard for most authenticator apps)
let totp30 = TOTP(key: key, digest: .sha256, interval: 30)

// 60 seconds
let totp60 = TOTP(key: key, digest: .sha256, interval: 60)
```

### Verifying Codes with Range Tolerance

To account for clock drift or user delays, generate multiple codes within a range:

```swift
let totp = TOTP(key: key, digest: .sha256)

// Generate codes for current time plus/minus 1 interval
let codes = totp.generate(time: Date(), range: 1)
// Returns 3 codes: [previous, current, next]

// Check if user's code matches any valid code
let userCode = "482719"
let isValid = codes.contains(userCode)
```

For HOTP, range generation works similarly:

```swift
let hotp = HOTP(key: key, digest: .sha256)

// Generate codes around counter 5
let codes = hotp.generate(counter: 5, range: 2)
// Returns 5 codes: [3, 4, 5, 6, 7]
```

### Static Generation Methods

For one-off code generation, use the static methods:

```swift
// Generate TOTP without creating an instance
let code = TOTP.generate(
    key: key,
    digest: .sha256,
    digits: .six,
    interval: 30,
    time: Date()
)

// Generate HOTP without creating an instance
let code = HOTP.generate(
    key: key,
    digest: .sha256,
    digits: .six,
    counter: 0
)
```

## Topics

### OTP Types

- ``TOTP``
- ``HOTP``

### Configuration

- ``OTPDigits``
- ``OTPDigest``
