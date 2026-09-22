#if bcrypt
internal import Bcrypt

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
    ) throws(BcryptError) -> [UInt8]
    where Password: DataProtocol {
        do {
            return try Bcrypt.hash(password: password.copyBytes(), cost: self.cost)
        } catch {
            throw .init(error)
        }
    }

    public func verify<Password, Digest>(
        _ password: Password,
        created digest: Digest
    ) throws(BcryptError) -> Bool
    where Password: DataProtocol, Digest: DataProtocol {
        do {
            return try Bcrypt.verify(password: password.copyBytes(), against: digest.copyBytes())
        } catch {
            throw .init(error)
        }
    }
}
#endif
