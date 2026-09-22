import Authentication
import Testing

@Suite("Password Tests")
struct PasswordTests {
    #if bcrypt
    @Test("BcryptHasher hashes and verifies passwords")
    func bcryptHasher() throws {
        let hash = try VaporBcrypt.hash("vapor")
        #expect(hash != "vapor")
        let hasher = BcryptHasher(cost: 12)
        #expect(try hasher.verify("vapor", created: hash))
        #expect(try VaporBcrypt.verify("vapor", created: hash))

        let hash2 = try hasher.hash("vapor")
        #expect(hash2 != hash)
        #expect(hash2 != "vapor")
        #expect(try hasher.verify("vapor", created: hash2))
        #expect(try VaporBcrypt.verify("vapor", created: hash2))
    }
    #endif

    @Test("PlaintextHasher hashes and verifies passwords")
    func plaintextHasher() throws {
        let hash = "vapor"
        let hasher = PlaintextHasher()
        #expect(try hasher.verify("vapor", created: hash))
        #expect(try PlaintextHasher().verify("vapor", created: hash))

        let hash2 = try hasher.hash("vapor")
        #expect(hash2 == "vapor")
        #expect(try hasher.verify("vapor", created: hash2))
        #expect(try PlaintextHasher().verify("vapor", created: hash2))
    }
}
