#if canImport(FoundationEssentials)
public import FoundationEssentials
#else
public import Foundation
#endif
internal import CVaporAuthBcrypt

// MARK: bcrypt

/// Creates and verifies bcrypt hashes.
///
/// Use BcryptDigest to create hashes for sensitive information like passwords.
///
///     try BcryptDigest.hash("vapor", cost: 12)
///
/// bcrypt uses a random salt each time it creates a hash. To verify hashes, use the `verify(_:matches)` method.
///
///     let hash = try BcryptDigest.hash("vapor", cost: 12)
///     try BcryptDigest.verify("vapor", created: hash) // true
///
/// https://en.wikipedia.org/wiki/bcrypt
public enum BcryptDigest: Sendable {
    /// Creates a new bcrypt hash with a randomly generated salt.
    /// The result can be stored in a database.
    /// parameters:
    ///     - plaintext: Plaintext data to hash.
    ///     - cost: Desired complexity. Larger `cost` values take longer to hash and verify. Default is 12.
    /// - throws: ``BcryptError`` if hashing fails or if data conversion fails.
    /// - returns: Newly created bcrypt hash.
    public static func hash(_ plaintext: String, cost: Int = 12) throws -> String {
        guard cost >= BCRYPT_MINLOGROUNDS && cost <= 31 else {
            throw BcryptError.invalidCost
        }
        return try Self.hash(plaintext, salt: Self.generateSalt(cost: cost))
    }


    /// Creates a bcrypt hash using a provided salt.
    ///
    /// This method allows you to specify your own salt for hashing. The salt can be either:
    /// - A 22-character raw salt (e.g., `J/dtt5ybYUTCJ/dtt5ybYO`)
    /// - A 29-character full salt including algorithm and cost (e.g., `$2b$12$J/dtt5ybYUTCJ/dtt5ybYO`)
    ///
    /// ```swift
    /// let hash = try BcryptDigest.hash("vapor", salt: "$2b$12$J/dtt5ybYUTCJ/dtt5ybYO")
    /// ```
    ///
    /// > Important: For most use cases, prefer ``hash(_:cost:)`` which generates a secure random salt automatically.
    ///
    /// - Parameters:
    ///   - plaintext: The plaintext string to hash.
    ///   - salt: A valid bcrypt salt (22 or 29 characters).
    /// - Returns: The bcrypt hash string.
    /// - Throws: ``BcryptError/invalidSalt`` if the salt format is invalid, or ``BcryptError/hashFailure`` if hashing fails.
    public static func hash(_ plaintext: String, salt: String) throws -> String {
        guard isSaltValid(salt) else {
            throw BcryptError.invalidSalt
        }

        let originalAlgorithm: Algorithm
        if salt.count == Algorithm.saltCount {
            // user provided salt
            originalAlgorithm = ._2b
        } else {
            // full salt, not user provided
            let revisionString = String(salt.prefix(4))
            if let parsedRevision = Algorithm(rawValue: revisionString) {
                originalAlgorithm = parsedRevision
            } else {
                throw BcryptError.invalidSalt
            }
        }

        // OpenBSD doesn't support 2y revision.
        let normalizedSalt: String
        if originalAlgorithm == Algorithm._2y {
            // Replace with 2b.
            normalizedSalt = Algorithm._2b.rawValue + salt.dropFirst(originalAlgorithm.revisionCount)
        } else {
            normalizedSalt = salt
        }

        var something = InlineArray<128, Int8>(repeating: 0)
        var data = ContiguousArray<Int8>(unsafeUninitializedCapacity: 128) { buffer, initializedCount in
//            var span = buffer.mutableSpan
//            let result = vapor_auth_bcrypt_hashpass(plaintext, normalizedSalt, &span)
//            guard result == 0 else {
//                throw BcryptError.hashFailure
//            }
//            print(buffer)
        }
//        print(data)


        var someSpan = something.mutableSpan
//        var hashedBytes = MutableSpan<Int8>()
        let result = vapor_auth_bcrypt_hashpass(plaintext, normalizedSalt, &something.mutableSpan)
        print(data)
//        print(someSpan)
//        guard result == 0 else {
//            throw BcryptError.hashFailure
//        }

        return try withUnsafeTemporaryAllocation(of: Int8.self, capacity: 128) { hashedBytes in
            guard let hashedBytesBase = hashedBytes.baseAddress else {
                throw BcryptError.internalError
            }
//            let hashingResult = vapor_auth_bcrypt_hashpass(
//                plaintext,
//                normalizedSalt,
//                hashedBytesBase,
//                128
//            )

            var hashedBytesSpan = hashedBytes.mutableSpan
            let result2 = vapor_auth_bcrypt_hashpass(plaintext, normalizedSalt, &hashedBytesSpan)

            guard result2 == 0 else {
                throw BcryptError.hashFailure
            }
            return originalAlgorithm.rawValue
                + String(cString: hashedBytesBase)
                    .dropFirst(originalAlgorithm.revisionCount)
        }
    }

    /// Verifies an existing bcrypt hash matches the supplied plaintext value. Verification works by parsing the salt and version from
    /// the existing digest and using that information to hash the plaintext data. If hash digests match, this method returns `true`.
    ///
    ///     let hash = try BcryptDigest.hash("vapor", cost: 4)
    ///     try BcryptDigest.verify("vapor", created: hash) // true
    ///     try BcryptDigest.verify("foo", created: hash) // false
    ///
    /// - parameters:
    ///     - plaintext: Plaintext data to digest and verify.
    ///     - hash: Existing bcrypt hash to parse version, salt, and existing digest from.
    /// - throws: `CryptoError` if hashing fails or if data conversion fails.
    /// - returns: `true` if the hash was created from the supplied plaintext data.
    public static func verify(_ plaintext: String, created hash: String) throws -> Bool {
        guard let hashVersion = Algorithm(rawValue: String(hash.prefix(4))) else {
            throw BcryptError.invalidHash
        }

        let hashSalt = String(hash.prefix(hashVersion.fullSaltCount))
        guard !hashSalt.isEmpty, hashSalt.count == hashVersion.fullSaltCount else {
            throw BcryptError.invalidHash
        }

        let hashChecksum = String(hash.suffix(hashVersion.checksumCount))
        guard !hashChecksum.isEmpty, hashChecksum.count == hashVersion.checksumCount else {
            throw BcryptError.invalidHash
        }

        let messageHash = try Self.hash(plaintext, salt: hashSalt)
        let messageHashChecksum = String(messageHash.suffix(hashVersion.checksumCount))
        return messageHashChecksum.secureCompare(to: hashChecksum)
    }

    // MARK: Private

    /// Generates string (29 chars total) containing the algorithm information + the cost + base-64 encoded 22 character salt
    ///
    ///     E.g:  $2b$05$J/dtt5ybYUTCJ/dtt5ybYO
    ///           $AA$ => Algorithm
    ///              $CC$ => Cost
    ///                  SSSSSSSSSSSSSSSSSSSSSS => Salt
    ///
    /// Allowed charset for the salt: [./A-Za-z0-9]
    ///
    /// - parameters:
    ///     - cost: Desired complexity. Larger `cost` values take longer to hash and verify.
    ///     - algorithm: Revision to use (2b by default)
    ///     - seed: Salt (without revision data). Generated if not provided. Must be 16 chars long.
    /// - returns: Complete salt
    private static func generateSalt(cost: Int, algorithm: Algorithm = ._2b, seed: [UInt8]? = nil) throws -> String {
        let randomData: [UInt8]
        if let seed = seed {
            randomData = seed
        } else {
            randomData = [UInt8].random(count: 16)
        }
        let encodedSalt = try base64Encode(randomData)

        return
            algorithm.rawValue +
            (cost < 10 ? "0\(cost)" : "\(cost)" ) + // 0 padded
            "$" +
            encodedSalt
    }

    /// Checks whether the provided salt is valid or not
    ///
    /// - parameters:
    ///     - salt: Salt to be checked
    /// - returns: True if the provided salt is valid
    private static func isSaltValid(_ salt: String) -> Bool {
        // Includes revision and cost info (count should be 29)
        let revisionString = String(salt.prefix(4))
        if let algorithm = Algorithm(rawValue: revisionString) {
            return salt.count == algorithm.fullSaltCount
        } else {
            // Does not include revision and cost info (count should be 22)
            return salt.count == Algorithm.saltCount
        }
    }

    /// Encodes the provided plaintext using OpenBSD's custom base-64 encoding (Radix-64)
    ///
    /// - parameters:
    ///     - data: Data to be base64 encoded.
    /// - returns: Base 64 encoded plaintext
    private static func base64Encode(_ data: [UInt8]) throws -> String {
        try withUnsafeTemporaryAllocation(of: Int8.self, capacity: 25) { encodedBytes in
            guard let encodedBytesBase = encodedBytes.baseAddress else {
                throw BcryptError.internalError
            }
            // data.mutableSpan
            let res = data.withUnsafeBytes { bytes in
                vapor_auth_encode_base64(encodedBytesBase, bytes.baseAddress?.assumingMemoryBound(to: UInt8.self), bytes.count)
            }
            assert(res == 0, "base64 convert failed")
            return String(cString: encodedBytesBase)
        }
    }

    /// Specific bcrypt algorithm.
    private enum Algorithm: String, RawRepresentable {
        /// older version
        case _2a = "$2a$"
        /// format specific to the crypt_blowfish bcrypt implementation, identical to `2b` in all but name.
        case _2y = "$2y$"
        /// latest revision of the official bcrypt algorithm, current default
        case _2b = "$2b$"

        /// Revision's length, including the `$` symbols
        var revisionCount: Int {
            return 4
        }

        /// Salt's length (includes revision and cost info)
        var fullSaltCount: Int {
            return 29
        }

        /// Checksum's length
        var checksumCount: Int {
            return 31
        }

        /// Salt's length (does NOT include neither revision nor cost info)
        static var saltCount: Int {
            return 22
        }
    }
}

public enum BcryptError: Swift.Error, CustomStringConvertible, LocalizedError, Sendable {
    case invalidCost
    case invalidSalt
    case hashFailure
    case invalidHash
    case internalError

    public var errorDescription: String? {
        return self.description
    }

    public var description: String {
        return "bcrypt error: \(self.reason)"
    }

    var reason: String {
        switch self {
        case .invalidCost:
            return "Cost should be between 4 and 31"
        case .invalidSalt:
            return "Provided salt has the incorrect format"
        case .hashFailure:
            return "Unable to compute hash"
        case .invalidHash:
            return "Invalid hash formatting"
        case .internalError:
            return "Internal bcrypt error"
        }
    }
}

extension Array where Element == UInt8 {
    static func random(count: Int) -> [Element] {
        var array: [Element] = .init(repeating: 0, count: count)
        (0..<count).forEach { array[$0] = Element.random(in: .min ... .max) }
        return array
    }
}
