#if canImport(FoundationEssentials)
public import Foundation
#else
public import Foundation
#endif

@nonexhaustive
public enum BcryptError: Swift.Error, CustomStringConvertible, LocalizedError, Sendable {
    case invalidCost
    case invalidSalt
    case hashFailure
    case invalidHash
    case internalError

    public var errorDescription: String? {
        return self.description
    }

    public var description: String {
        return "bcrypt error: \(self.reason)"
    }

    var reason: String {
        switch self {
        case .invalidCost:
            return "Cost should be between 4 and 31"
        case .invalidSalt:
            return "Provided salt has the incorrect format"
        case .hashFailure:
            return "Unable to compute hash"
        case .invalidHash:
            return "Invalid hash formatting"
        case .internalError:
            return "Internal bcrypt error"
        }
    }
}