#if canImport(FoundationEssentials)
public import FoundationEssentials
#else
public import Foundation
#endif

public struct BcryptHasher: PasswordHasher {
    let cost: Int
    public init(cost: Int = 12) {
        self.cost = cost
    }

    public func hash<Password>(
        _ password: Password
    ) throws -> [UInt8]
    where Password: DataProtocol {
        let string = String(decoding: password, as: UTF8.self)
        let digest = try BcryptDigest.hash(string, cost: self.cost)
        return .init(digest.utf8)
    }

    public func verify<Password, Digest>(
        _ password: Password,
        created digest: Digest
    ) throws -> Bool
    where Password: DataProtocol, Digest: DataProtocol {
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
