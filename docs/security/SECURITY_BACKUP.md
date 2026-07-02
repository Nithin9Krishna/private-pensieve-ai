# Security and Backup Design

## Local database encryption
- Use SQLCipher or platform-equivalent encrypted SQLite.
- Generate a random database key on first launch.
- Store key in iOS Keychain / Android Keystore.
- Never sync key or database automatically.

## Biometric unlock
- Optional lock gate for opening the vault.
- Biometrics protect access to the local key; they do not replace delete/export controls.

## Delete all data
- Stop voice recording/playback.
- Close database handles.
- Delete database, temporary audio, generated previews, and backup staging files.
- Recreate empty vault.

## Backup format
Extension: `.pensieve`

Contains:
- encrypted database export
- version metadata
- `created_at`
- checksum

## Import flow
- Validate extension and checksum.
- Decrypt into staging location.
- Show restore preview.
- Require explicit confirmation before replacing local vault.

## Privacy dashboard values
- Account: Not required
- Server: Not used
- Cloud: Not used
- Internet: Not required
- AI: On-device
- Memories: Encrypted locally
- Backup: Manual encrypted export only
- Tracking: None
