import Authentication
import CryptoExtras
import Testing

@Suite("PBKDF2 Tests")
struct PBKDF2Tests {
    @Test("Hash and verify round trip")
    func hashAndVerify() throws {
        let hasher = PBKDF2Hasher()
        let password = "secretPassword123"
        let digest = try hasher.hash(password)
        let result = try hasher.verify(password, created: digest)
        #expect(result, "Password should verify against its own hash")
    }

    @Test("Verification fails for wrong password")
    func verifyFails() throws {
        let hasher = PBKDF2Hasher()
        let digest = try hasher.hash("correctPassword")
        let result = try hasher.verify("wrongPassword", created: digest)
        #expect(result == false)
    }

    @Test("Empty digest returns false")
    func emptyDigest() throws {
        let hasher = PBKDF2Hasher()
        let result = try hasher.verify("password", created: "")
        #expect(result == false)
    }

    @Test("Invalid digest format returns false")
    func invalidDigestFormat() throws {
        let hasher = PBKDF2Hasher()
        // No separator
        let result1 = try hasher.verify("password", created: "invaliddigest")
        #expect(result1 == false)

        // Multiple separators
        let result2 = try hasher.verify("password", created: "part1$part2$part3")
        #expect(result2 == false)
    }

    @Test("Invalid base64 in digest returns false")
    func invalidBase64() throws {
        let hasher = PBKDF2Hasher()
        let result = try hasher.verify("password", created: "!!!invalid$###base64")
        #expect(result == false)
    }

    @Test("Different hash functions produce different outputs")
    func differentHashFunctions() throws {
        let sha256Hasher = PBKDF2Hasher(pseudoRandomFunction: .sha256)
        let sha512Hasher = PBKDF2Hasher(pseudoRandomFunction: .sha512)

        let password = "testPassword"
        let digest256 = try sha256Hasher.hash(password)
        let digest512 = try sha512Hasher.hash(password)

        #expect(digest256 != digest512)

        #expect(try sha256Hasher.verify(password, created: digest256))
        #expect(try sha512Hasher.verify(password, created: digest512))

        #expect(try sha256Hasher.verify(password, created: digest512) == false)
        #expect(try sha512Hasher.verify(password, created: digest256) == false)
    }

    @Test("Same password with different salts produces different hashes")
    func differentSalts() throws {
        let hasher = PBKDF2Hasher()
        let password = "samePassword"

        let digest1 = try hasher.hash(password)
        let digest2 = try hasher.hash(password)

        #expect(digest1 != digest2)

        #expect(try hasher.verify(password, created: digest1))
        #expect(try hasher.verify(password, created: digest2))
    }

    @Test("Empty password can be hashed and verified")
    func emptyPassword() throws {
        let hasher = PBKDF2Hasher()
        let digest = try hasher.hash("")
        let result = try hasher.verify("", created: digest)
        #expect(result)
    }

    @Test("Unicode passwords work correctly")
    func unicodePassword() throws {
        let hasher = PBKDF2Hasher()
        let password = "пароль密码🔐"
        let digest = try hasher.hash(password)
        let result = try hasher.verify(password, created: digest)
        #expect(result)
    }

    @Test("Long password works correctly")
    func longPassword() throws {
        let hasher = PBKDF2Hasher()
        let password = String(repeating: "a", count: 10000)
        let digest = try hasher.hash(password)
        let result = try hasher.verify(password, created: digest)
        #expect(result)
    }

    @Test(
        "All supported hash functions work",
        arguments: [
            KDF.Insecure.PBKDF2.HashFunction.sha256,
            KDF.Insecure.PBKDF2.HashFunction.sha384,
            KDF.Insecure.PBKDF2.HashFunction.sha512,
            KDF.Insecure.PBKDF2.HashFunction.insecureSHA1,
            KDF.Insecure.PBKDF2.HashFunction.insecureSHA224,
        ])
    func allHashFunctions(hashFunction: KDF.Insecure.PBKDF2.HashFunction) throws {
        let hasher = PBKDF2Hasher(pseudoRandomFunction: hashFunction, iterations: 1000)
        let password = "testAllFunctions"
        let digest = try hasher.hash(password)
        let result = try hasher.verify(password, created: digest)
        #expect(result, "Hash function should work for hashing and verification")
    }
}
