import Crypto
import Foundation
import Testing

@testable import Authentication

@Suite("OTP Tests")
struct OTPTests {
    /// Basic TOTP tests using some RFC 6238 test vectors.
    /// https://tools.ietf.org/html/rfc6238.html
    @Test(
        "TOTP basic generation with RFC 6238 test vectors",
        arguments: [
            (key: "12345678901234567890", digest: OTPDigest.sha1, otp: "94287082"),
            (key: "12345678901234567890123456789012", digest: OTPDigest.sha256, otp: "46119246"),
            (key: "1234567890123456789012345678901234567890123456789012345678901234", digest: OTPDigest.sha512, otp: "90693936"),
        ])
    func totpBasic(key: String, digest: OTPDigest, otp: String) throws {
        let time = Date(timeIntervalSince1970: 59)
        let keyData = try #require(key.data(using: .ascii))
        let symmetricKey = SymmetricKey(data: keyData)
        let result = TOTP(key: symmetricKey, digest: digest, digits: .eight, interval: 30).generate(time: time)
        #expect(result == otp)
    }

    @Test("TOTP range generation")
    func totpRange() throws {
        let time = Date(timeIntervalSince1970: 60)
        let preTime = Date(timeIntervalSince1970: 30)
        let postTime = Date(timeIntervalSince1970: 90)

        let keyData = try #require("12345678901234567890".data(using: .ascii))
        let key = SymmetricKey(data: keyData)
        let totp = TOTP(key: key, digest: .sha1, digits: .eight, interval: 30)
        let codes = totp.generate(time: time, range: 1)
        #expect(codes.count == 3)

        let cur = totp.generate(time: time)
        let pre = totp.generate(time: preTime)
        let post = totp.generate(time: postTime)

        #expect(Set([cur, pre, post]).count == 3)
        #expect(codes.contains(totp.generate(time: time)))
        #expect(codes.contains(totp.generate(time: preTime)))
        #expect(codes.contains(totp.generate(time: postTime)))
    }

    /// Basic HOTP tests using RFC 4226 test vectors.
    /// https://tools.ietf.org/html/rfc4226#page-32
    @Test(
        "HOTP basic generation with RFC 4226 test vectors",
        arguments: [
            (counter: 0, otp: "755224"),
            (counter: 1, otp: "287082"),
            (counter: 2, otp: "359152"),
            (counter: 3, otp: "969429"),
            (counter: 4, otp: "338314"),
            (counter: 5, otp: "254676"),
            (counter: 6, otp: "287922"),
            (counter: 7, otp: "162583"),
            (counter: 8, otp: "399871"),
            (counter: 9, otp: "520489"),
        ])
    func hotpBasic(counter: UInt64, otp: String) throws {
        let keyData = try #require("12345678901234567890".data(using: .ascii))
        let key = SymmetricKey(data: keyData)
        let hotp = HOTP(key: key, digest: .sha1).generate(counter: counter)
        #expect(hotp == otp)
    }

    @Test("HOTP range generation")
    func hotpRange() {
        let key = SymmetricKey(size: .bits128)
        let codes = HOTP(key: key, digest: .sha1).generate(counter: 10, range: 1)
        #expect(codes.count == 3)
    }
}
