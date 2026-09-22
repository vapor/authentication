#if bcrypt
internal import Bcrypt

@nonexhaustive
public enum BcryptError: Swift.Error, CustomStringConvertible, Sendable {
    case invalidCost
    case invalidSalt
    case hashFailure
    case invalidHash
    case internalError
    case emptyPassword
    case passwordTooLong

    public var errorDescription: String? {
        return self.description
    }

    public var description: String {
        return "bcrypt error: \(self.reason)"
    }

    var reason: String {
        switch self {
        case .invalidCost:
            "Cost should be between 4 and 31"
        case .invalidSalt:
            "Provided salt has the incorrect format"
        case .hashFailure:
            "Unable to compute hash"
        case .invalidHash:
            "Invalid hash formatting"
        case .internalError:
            "Internal bcrypt error"
        case .emptyPassword:
            "Password must not be empty"
        case .passwordTooLong:
            "Password must not be longer than 72 bytes"
        }
    }

    /// Maps an error from the underlying `Bcrypt` implementation to the public ``BcryptError``.
    init(_ error: Bcrypt::BcryptError) {
        self =
            switch error {
            case .invalidCost: .invalidCost
            case .invalidSalt, .invalidSaltLength, .invalidSettings: .invalidSalt
            case .invalidHash, .invalidVersion: .invalidHash
            case .emptyPassword: .emptyPassword
            case .passwordTooLong: .passwordTooLong
            @unknown default: .internalError
            }
    }
}
#endif
