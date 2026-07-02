package com.privatepensieve.app.vault

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.security.KeyStore
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey

/**
 * Android Keystore key manager for vault encryption.
 * Key is hardware-backed when available. Never leaves the device.
 * Key is destroyed on app uninstall (setUserAuthenticationRequired=false for V1).
 *
 * V1: Generates AES-256-GCM key. Ready for SQLCipher integration.
 * V2: Will use this key as SQLCipher passphrase.
 */
object VaultKeyManager {

    private const val KEYSTORE_PROVIDER = "AndroidKeyStore"
    private const val KEY_ALIAS = "pensieve_vault_key"

    /**
     * Get or create the vault encryption key.
     */
    fun getOrCreateKey(): SecretKey {
        val existingKey = getKey()
        if (existingKey != null) return existingKey
        return generateKey()
    }

    /**
     * Check if a vault key exists.
     */
    fun hasKey(): Boolean = getKey() != null

    /**
     * Delete the vault key (used during factory reset).
     */
    fun deleteKey() {
        val keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER)
        keyStore.load(null)
        if (keyStore.containsAlias(KEY_ALIAS)) {
            keyStore.deleteEntry(KEY_ALIAS)
        }
    }

    private fun getKey(): SecretKey? {
        val keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER)
        keyStore.load(null)
        return keyStore.getKey(KEY_ALIAS, null) as? SecretKey
    }

    private fun generateKey(): SecretKey {
        val keyGenerator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            KEYSTORE_PROVIDER
        )
        val spec = KeyGenParameterSpec.Builder(
            KEY_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(256)
            // V1: No user authentication required (app-level gate handles this)
            // V2: setUserAuthenticationRequired(true) + biometric
            .build()

        keyGenerator.init(spec)
        return keyGenerator.generateKey()
    }
}
