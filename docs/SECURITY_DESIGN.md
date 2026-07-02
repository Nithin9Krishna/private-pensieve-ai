# Security Design — Initial Contract

## Goal
Protect local vault confidentiality and backup integrity without introducing a server.

## Proposed approach requiring platform validation
- Database encryption: SQLCipher-compatible encrypted SQLite layer.
- Key storage: Keychain (iOS) / Android Keystore (Android).
- Local app access: user passcode plus optional biometric gate.
- Backup: versioned container encrypted with authenticated encryption, using a password-derived key and per-backup salt/nonce.
- Release logging: never log user content, keys, or decrypted backup data.

## Open decisions
- Final KDF selection and parameters after platform/library compatibility review.
- Exact schema of `.pensieve` export container.
- Secure deletion expectations by platform and storage medium.
