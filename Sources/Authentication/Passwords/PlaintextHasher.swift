#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

private struct PlaintextHasher: PasswordHasher {
    func hash<Password>(_ password: Password) throws -> [UInt8]
        where Password: DataProtocol
    {
        password.copyBytes()
    }

    func verify<Password, Digest>(
        _ password: Password,
        created digest: Digest
    ) throws -> Bool
        where Password: DataProtocol, Digest: DataProtocol
    {
        password.copyBytes() == digest.copyBytes()
    }
}