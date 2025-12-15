import Authentication
import Testing

@Suite("bcrypt Tests")
struct BcryptTests {
    @Test("Hash includes correct version prefix")
    func version() throws {
        let digest = try VaporBcrypt.hash("foo", cost: 6)
        #expect(digest.hasPrefix("$2b$06$"))
    }

    @Test("Verification fails for wrong password")
    func verifyFails() throws {
        let digest = try VaporBcrypt.hash("foo", cost: 6)
        let result = try VaporBcrypt.verify("bar", created: digest)
        #expect(result == false)
    }

    @Test("Invalid minimum cost throws error")
    func invalidMinCost() {
        #expect(throws: BcryptError.self) {
            try VaporBcrypt.hash("foo", cost: 1)
        }
    }

    @Test("Invalid maximum cost throws error")
    func invalidMaxCost() {
        #expect(throws: BcryptError.self) {
            try VaporBcrypt.hash("foo", cost: 32)
        }
    }

    @Test("Invalid salt throws error")
    func invalidSalt() {
        #expect(throws: BcryptError.self) {
            try VaporBcrypt.verify("", created: "foo")
        }
    }

    @Test(
        "Verify known hashes",
        arguments: [
            (hash: "$2a$05$CCCCCCCCCCCCCCCCCCCCC.E5YPO9kmyuRGyh0XouQYb4YMJKvyOeW", message: "U*U"),
            (hash: "$2a$05$CCCCCCCCCCCCCCCCCCCCC.VGOzA784oUp/Z0DY336zx7pLYAy0lwK", message: "U*U*"),
            (hash: "$2a$05$XXXXXXXXXXXXXXXXXXXXXOAcXxm9kjPGEMsLznoKqmqw7tc8WCx4a", message: "U*U*U"),
            (
                hash: "$2a$05$abcdefghijklmnopqrstuu5s2v8.iXieOjg/.AySBTTZIIVFJeBui",
                message: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789chars after 72 are ignored"
            ),
            (hash: "$2a$04$TI13sbmh3IHnmRepeEFoJOkVZWsn5S1O8QOwm8ZU5gNIpJog9pXZm", message: "vapor"),
            (hash: "$2y$11$kHM/VXmCVsGXDGIVu9mD8eY/uEYI.Nva9sHgrLYuLzr0il28DDOGO", message: "Vapor3"),
            (hash: "$2a$06$DCq7YPn5Rq63x1Lad4cll.TV4S6ytwfsfvkgY8jIucDrjc8deX1s.", message: ""),
            (hash: "$2a$06$m0CrhHm10qJ3lXRY.5zDGO3rS2KdeeWLuGmsfGlMfOxih58VYVfxe", message: "a"),
            (hash: "$2a$06$If6bvum7DFjUnE9p2uDeDu0YHzrHM6tf.iqN8.yx.jNN1ILEf7h0i", message: "abc"),
            (hash: "$2a$06$.rCVZVOThsIa97pEDOxvGuRRgzG64bvtJ0938xuqzv18d3ZpQhstC", message: "abcdefghijklmnopqrstuvwxyz"),
            (hash: "$2a$06$fPIsBO8qRqkjj273rfaOI.HtSV9jLDpTbZn782DC6/t7qT67P6FfO", message: "~!@#$%^&*()      ~!@#$%^&*()PNBFRD"),
        ])
    func verify(hash: String, message: String) throws {
        let result = try VaporBcrypt.verify(message, created: hash)
        #expect(result, "\(message): did not match \(hash)")
    }

    @Test("Verify known vapor hash")
    func onlineVapor() throws {
        let result = try VaporBcrypt.verify("vapor", created: "$2a$10$e.qg8zwKLHu3ur5rPF97ouzCJiJmZ93tiwNekDvTQfuhyu97QaUk.")
        #expect(result)
    }
}
