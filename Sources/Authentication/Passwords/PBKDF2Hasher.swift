public import CryptoExtras

#if canImport(FoundationEssentials)
public import FoundationEssentials
#else
public import Foundation
#endif

/// A password hasher using PBKDF2 with configurable hash function and iterations.
///
/// The output format is a modular crypt format string:
/// `$pbkdf2-<algorithm>$<iterations>$<base64-salt>$<base64-hash>`
///
/// This format is compatible with passlib and other common PBKDF2 implementations.
/// See: https://passlib.readthedocs.io/en/stable/lib/passlib.hash.pbkdf2_digest.html
public struct PBKDF2Hasher: PasswordHasher {
    let pseudoRandomFunction: KDF.Insecure.PBKDF2.HashFunction
    let outputByteCount: Int
    let iterations: Int

    /// Creates a PBKDF2 password hasher.
    ///
    /// - Parameters:
    ///   - pseudoRandomFunction: The hash function to use. Defaults to SHA-256.
    ///   - iterations: The number of PBKDF2 iterations. If nil, uses OWASP-recommended
    ///     defaults based on the hash function.
    /// - Note: the parameters passed in here will only be used for hashing, verification
    /// will rely solely on the parameters inside of the hash.
    public init(
        pseudoRandomFunction: KDF.Insecure.PBKDF2.HashFunction = .sha256,
        iterations: Int? = nil
    ) {
        self.pseudoRandomFunction = pseudoRandomFunction

        // OWASP recommendations: https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html#pbkdf2
        let defaultIterations: Int =
            switch pseudoRandomFunction {
            case .sha256: 600_000
            case .sha384: 400_000
            case .sha512: 210_000
            case .insecureSHA1: 1_300_000
            case .insecureSHA224: 800_000
            case .insecureMD5: 1_600_000
            default: fatalError("Unsupported hash function")
            }
        self.iterations = iterations ?? defaultIterations

        self.outputByteCount =
            switch pseudoRandomFunction {
            case .sha256: 32
            case .sha384: 48
            case .sha512: 64
            case .insecureSHA224: 28
            case .insecureSHA1: 20
            case .insecureMD5: 16
            default: fatalError("Unsupported hash function")
            }
    }

    /// Hashes a password using PBKDF2.
    ///
    /// - Parameter password: The password to hash.
    /// - Returns: The hash string as UTF-8 bytes.
    public func hash<Password>(_ password: Password) throws -> [UInt8] where Password: DataProtocol {
        let salt = [UInt8].random(count: 16)
        let key = try KDF.Insecure.PBKDF2.deriveKey(
            from: password,
            salt: salt,
            using: pseudoRandomFunction,
            outputByteCount: outputByteCount,
            unsafeUncheckedRounds: iterations
        )

        let keyData = unsafe key.withUnsafeBytes { unsafe Data($0) }

        // PHC format: $pbkdf2-<alg>$<iterations>$<b64salt>$<b64hash>
        let algorithmId = Self.algorithmIdentifier(for: pseudoRandomFunction)
        let b64Salt = Data(salt).base64EncodedString()
        let b64Hash = keyData.base64EncodedString()

        let phcString = "$pbkdf2-\(algorithmId)$\(iterations)$\(b64Salt)$\(b64Hash)"
        return Array(phcString.utf8)
    }

    /// Verifies a password against a hash.
    ///
    /// - Parameters:
    ///   - password: The password to verify.
    ///   - digest: The stored hash.
    /// - Returns: `true` if the password matches, `false` otherwise.
    public func verify<Password, Digest>(_ password: Password, created digest: Digest) throws -> Bool
    where Password: DataProtocol, Digest: DataProtocol {
        guard !digest.isEmpty else { return false }

        let digestString = String(decoding: digest, as: UTF8.self)
        guard let parsed = Self.parsePassword(digestString), parsed.algorithm == pseudoRandomFunction else {
            return false
        }

        let key = try KDF.Insecure.PBKDF2.deriveKey(
            from: password,
            salt: parsed.salt,
            using: parsed.algorithm,
            outputByteCount: parsed.hash.count,
            unsafeUncheckedRounds: parsed.iterations
        )

        let keyData = unsafe key.withUnsafeBytes { unsafe Data($0) }

        return keyData.elementsEqual(parsed.hash)
    }

    private struct ParsedPassword {
        let algorithm: KDF.Insecure.PBKDF2.HashFunction
        let iterations: Int
        let salt: [UInt8]
        let hash: [UInt8]
    }

    private static func parsePassword(_ string: String) -> ParsedPassword? {
        // Expected format: $pbkdf2-<alg>$<iterations>$<b64salt>$<b64hash>
        let parts = string.split(separator: "$", omittingEmptySubsequences: true)
        guard parts.count == 4 else { return nil }

        // Parse algorithm
        let algPart = String(parts[0])
        guard
            algPart.hasPrefix("pbkdf2-"),
            let algorithm = hashFunction(from: String(algPart.dropFirst(7)))
        else {
            return nil
        }

        // Parse iterations
        guard let iterations = Int(parts[1]) else {
            return nil
        }

        // Parse salt
        guard let saltData = Data(base64Encoded: String(parts[2])) else {
            return nil
        }

        // Parse hash
        guard let hashData = Data(base64Encoded: String(parts[3])) else {
            return nil
        }

        return ParsedPassword(
            algorithm: algorithm,
            iterations: iterations,
            salt: Array(saltData),
            hash: Array(hashData)
        )
    }

    private static func algorithmIdentifier(for hashFunction: KDF.Insecure.PBKDF2.HashFunction) -> String {
        switch hashFunction {
        case .sha256: "sha256"
        case .sha384: "sha384"
        case .sha512: "sha512"
        case .insecureSHA1: "sha1"
        case .insecureSHA224: "sha224"
        case .insecureMD5: "md5"
        default: fatalError("Unsupported hash function")
        }
    }

    private static func hashFunction(from identifier: String) -> KDF.Insecure.PBKDF2.HashFunction? {
        switch identifier {
        case "sha256": .sha256
        case "sha384": .sha384
        case "sha512": .sha512
        case "sha1": .insecureSHA1
        case "sha224": .insecureSHA224
        case "md5": .insecureMD5
        default: nil
        }
    }
}
