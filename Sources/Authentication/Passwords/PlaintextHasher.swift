#if canImport(FoundationEssentials)
public import FoundationEssentials
#else
public import Foundation
#endif

public struct PlaintextHasher: PasswordHasher {
    public init() {}

    public func hash<Password>(_ password: Password) throws(Never) -> [UInt8]
    where Password: DataProtocol {
        password.copyBytes()
    }

    public func verify<Password, Digest>(
        _ password: Password,
        created digest: Digest
    ) throws(Never) -> Bool
    where Password: DataProtocol, Digest: DataProtocol {
        password.copyBytes() == digest.copyBytes()
    }
}
