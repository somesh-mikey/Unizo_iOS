//
//  MessageEncryptionService.swift
//  Unizo_iOS
//
//  AES-GCM symmetric encryption for chat messages
//

import CryptoKit
import Foundation

struct MessageEncryptionService {

    /// Derives a symmetric key from two user IDs (sorted alphabetically for consistency)
    static func deriveKey(userA: String, userB: String) -> SymmetricKey {
        let sorted = [userA, userB].sorted().joined()
        let data = Data(sorted.utf8)
        let hashed = SHA256.hash(data: data)
        return SymmetricKey(data: hashed)
    }

    /// Encrypts a message using AES-GCM with the given key
    static func encrypt(_ message: String, key: SymmetricKey) throws -> String {
        let data = Data(message.utf8)
        let sealed = try AES.GCM.seal(data, using: key)
        guard let combined = sealed.combined else {
            throw EncryptionError.encryptionFailed
        }
        return combined.base64EncodedString()
    }

    /// Decrypts a message using AES-GCM with the given key
    static func decrypt(_ encrypted: String, key: SymmetricKey) throws -> String {
        guard let data = Data(base64Encoded: encrypted) else {
            throw EncryptionError.invalidData
        }
        let sealed = try AES.GCM.SealedBox(combined: data)
        let decrypted = try AES.GCM.open(sealed, using: key)
        guard let result = String(data: decrypted, encoding: .utf8) else {
            throw EncryptionError.invalidData
        }
        return result
    }

    enum EncryptionError: LocalizedError {
        case invalidData
        case encryptionFailed

        var errorDescription: String? {
            switch self {
            case .invalidData:
                return "Invalid encrypted data"
            case .encryptionFailed:
                return "Encryption failed"
            }
        }
    }
}
