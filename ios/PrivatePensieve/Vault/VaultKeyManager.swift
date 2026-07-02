// VaultKeyManager.swift
// Private Pensieve AI — iOS
// Keychain-based key management for vault encryption.
// V1: Generates and stores a random encryption key in Keychain.
// V2: This key will be used as the SQLCipher passphrase.

import Foundation
import Security

/// Manages the vault encryption key using iOS Keychain.
/// Key is bound to this device only (kSecAttrAccessibleWhenUnlockedThisDeviceOnly).
/// Key is destroyed on app uninstall.
final class VaultKeyManager {

    static let shared = VaultKeyManager()

    private let keychainService = "com.privatepensieve.vault"
    private let keychainAccount = "vault-encryption-key"
    private let keyLength = 32 // 256-bit key

    private init() {}

    // MARK: - Key Operations

    /// Get or create the vault encryption key.
    /// Returns a 256-bit key stored in Keychain.
    func getOrCreateKey() throws -> Data {
        if let existingKey = try? retrieveKey() {
            return existingKey
        }
        let newKey = generateRandomKey()
        try storeKey(newKey)
        return newKey
    }

    /// Delete the vault key (used during "Delete All" or factory reset).
    func deleteKey() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw VaultKeyError.deleteFailed(status)
        }
    }

    /// Check if a vault key exists (used to determine if vault is initialized).
    var hasKey: Bool {
        return (try? retrieveKey()) != nil
    }

    // MARK: - Private

    private func generateRandomKey() -> Data {
        var keyData = Data(count: keyLength)
        _ = keyData.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, keyLength, bytes.baseAddress!)
        }
        return keyData
    }

    private func storeKey(_ key: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: key,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Delete any existing key first
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw VaultKeyError.storeFailed(status)
        }
    }

    private func retrieveKey() throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw VaultKeyError.retrieveFailed(status)
        }
    }
}

// MARK: - Errors

enum VaultKeyError: LocalizedError {
    case storeFailed(OSStatus)
    case retrieveFailed(OSStatus)
    case deleteFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .storeFailed(let s): return "Keychain store failed: \(s)"
        case .retrieveFailed(let s): return "Keychain retrieve failed: \(s)"
        case .deleteFailed(let s): return "Keychain delete failed: \(s)"
        }
    }
}
