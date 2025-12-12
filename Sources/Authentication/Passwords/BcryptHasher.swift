#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

struct BcryptHasher: PasswordHasher {
    let cost: Int
    func hash<Password>(
        _ password: Password
    ) throws -> [UInt8]
        where Password: DataProtocol
    {
        let string = String(decoding: password, as: UTF8.self)
        let digest = try BcryptDigest.hash(string, cost: self.cost)
        return .init(digest.utf8)
    }

    func verify<Password, Digest>(
        _ password: Password,
        created digest: Digest
    ) throws -> Bool
        where Password: DataProtocol, Digest: DataProtocol
    {
        try BcryptDigest.verify(
            String(decoding: password.copyBytes(), as: UTF8.self),
            created: String(decoding: digest.copyBytes(), as: UTF8.self)
        )
    }
}

extension DataProtocol {
    func copyBytes() -> [UInt8] {
        Array(self)
    }
}