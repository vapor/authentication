#if bcrypt
    internal import Bcrypt

    // MARK: bcrypt

    /// Creates and verifies bcrypt hashes.
    ///
    /// Use VaporBcrypt to create hashes for sensitive information like passwords.
    ///
    ///     try VaporBcrypt.hash("vapor", cost: 12)
    ///
    /// bcrypt uses a random salt each time it creates a hash. To verify hashes, use the `verify(_:created:)` method.
    ///
    ///     let hash = try VaporBcrypt.hash("vapor", cost: 12)
    ///     try VaporBcrypt.verify("vapor", created: hash) // true
    ///
    /// https://en.wikipedia.org/wiki/bcrypt
    public enum VaporBcrypt: Sendable {
        /// Cost used when none is provided.
        static let defaultCost = 12

        /// Creates a new bcrypt hash with a randomly generated salt.
        /// The result can be stored in a database.
        /// parameters:
        ///     - plaintext: Plaintext data to hash.
        ///     - cost: Desired complexity. Larger `cost` values take longer to hash and verify. Default is 12.
        /// - throws: ``BcryptError`` if hashing fails or if data conversion fails.
        /// - returns: Newly created bcrypt hash.
        public static func hash(_ plaintext: String, cost: Int = 12) throws(BcryptError) -> String {
            do {
                return try Bcrypt.hash(password: plaintext, cost: cost)
            } catch {
                throw .init(error)
            }
        }

        /// Creates a bcrypt hash using a provided salt.
        ///
        /// This method allows you to specify your own salt for hashing. The salt can be either:
        /// - A 22-character raw salt (e.g., `J/dtt5ybYUTCJ/dtt5ybYO`), hashed with the `2b` revision and the default cost
        /// - A 29-character full salt including algorithm and cost (e.g., `$2b$12$J/dtt5ybYUTCJ/dtt5ybYO`)
        ///
        /// ```swift
        /// let hash = try VaporBcrypt.hash("vapor", salt: "$2b$12$J/dtt5ybYUTCJ/dtt5ybYO")
        /// ```
        ///
        /// > Important: For most use cases, prefer ``hash(_:cost:)`` which generates a secure random salt automatically.
        ///
        /// - Parameters:
        ///   - plaintext: The plaintext string to hash.
        ///   - salt: A valid bcrypt salt (22 or 29 characters).
        /// - Returns: The bcrypt hash string.
        /// - Throws: ``BcryptError/invalidSalt`` if the salt format is invalid, or ``BcryptError/hashFailure`` if hashing fails.
        public static func hash(_ plaintext: String, salt: String) throws(BcryptError) -> String {
            do {
                switch salt.utf8.count {
                case 22:
                    let digest = try Bcrypt.hash(password: plaintext.utf8Span.span, cost: 12, salt: salt.utf8Span.span)
                    return String(decoding: digest, as: UTF8.self)
                default:
                    return try Bcrypt.hash(password: plaintext, settings: salt)
                }
            } catch {
                throw .init(error)
            }
        }

        /// Verifies an existing bcrypt hash matches the supplied plaintext value. Verification works by parsing the salt and version from
        /// the existing digest and using that information to hash the plaintext data. If hash digests match, this method returns `true`.
        ///
        ///     let hash = try VaporBcrypt.hash("vapor", cost: 4)
        ///     try VaporBcrypt.verify("vapor", created: hash) // true
        ///     try VaporBcrypt.verify("foo", created: hash) // false
        ///
        /// - parameters:
        ///     - plaintext: Plaintext data to digest and verify.
        ///     - hash: Existing bcrypt hash to parse version, salt, and existing digest from.
        /// - throws: `BcryptError` if hashing fails or if data conversion fails.
        /// - returns: `true` if the hash was created from the supplied plaintext data.
        public static func verify(_ plaintext: String, created hash: String) throws(BcryptError) -> Bool {
            do {
                return try Bcrypt.verify(password: plaintext, against: hash)
            } catch {
                throw .init(error)
            }
        }
    }
#endif
