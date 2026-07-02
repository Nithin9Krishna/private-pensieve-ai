# User Flows — Private Pensieve AI

> End-to-end journey maps for all primary and secondary user flows.

---

## Flow 1: First-Time User Onboarding

```mermaid
flowchart TD
    A["App Launch (first time)"] --> B["Welcome Screen"]
    B --> C{"User taps CTA"}
    C -->|"Create My Private Vault"| D["Privacy Promise Screen"]
    C -->|"How privacy works"| D
    D --> E["Vault Protection Screen"]
    E --> F{"Create passcode"}
    F -->|"Passcode set"| G{"Enable biometrics?"}
    G -->|"Yes"| H["Biometric enrolled"]
    G -->|"No"| I["Skip biometrics"]
    H --> J["Offline Brain Setup"]
    I --> J
    J --> K{"Choose AI mode"}
    K -->|"Built-in AI"| L["Start Talking → Talk Tab"]
    K -->|"Download pack"| M["Download progress"] --> L
    K -->|"Basic mode"| L
```

**Duration target**: Under 60 seconds from launch to first voice interaction.

---

## Flow 2: Save a Voice Memory

```mermaid
flowchart TD
    A["Talk Tab (Idle)"] --> B["Hold/Tap Mic"]
    B --> C["Listening State"]
    C --> D["Release/Stop"]
    D --> E["Transcribing"]
    E --> F{"Confidence check"}
    F -->|"High confidence"| G["Thinking (AI processing)"]
    F -->|"Low confidence"| H["Transcript Review"]
    H -->|"Looks right"| G
    H -->|"Edit"| I["Edit transcript"] --> G
    H -->|"Don't save"| J["Return to Idle"]
    G --> K["AI Reply (Speaking)"]
    K --> L["Memory Preview: What I'll Remember"]
    L --> M{"User choice"}
    M -->|"Save all"| N["Saved confirmation"]
    M -->|"Edit a card"| O["Edit memory card"] --> N
    M -->|"Discard one"| P["Remove card"] --> L
    M -->|"Discard all"| J
    N --> Q["Return to Idle"]
```

**Key invariant**: No network call at any step. Audio file deleted after transcription unless retention is ON.

---

## Flow 3: Recall a Memory

```mermaid
flowchart TD
    A["Recall Tab"] --> B{"Input method"}
    B -->|"Voice"| C["Hold mic → Speak question"]
    B -->|"Text"| D["Type question"]
    B -->|"Suggested"| E["Tap suggested question"]
    C --> F["Process query"]
    D --> F
    E --> F
    F --> G["Query classifier"]
    G --> H["Metadata + full-text search"]
    H --> I["Rank candidates"]
    I --> J{"Evidence found?"}
    J -->|"Yes (1-5 cards)"| K["Context compressor"]
    K --> L["AI generates evidence-bound answer"]
    L --> M["Show: answer + evidence cards"]
    J -->|"No"| N["Show: 'I don't remember you telling me that yet.'"]
    N --> O["Offer: 'Would you like to talk about it now?'"]
    O -->|"Yes"| P["Navigate to Talk Tab"]
    O -->|"No"| A
    M --> Q{"User action"}
    Q -->|"Ask another"| A
    Q -->|"View memory"| R["Memory Detail"]
```

**Critical invariant**: If no evidence passes threshold, the EXACT text must be: `I don't remember you telling me that yet.`

---

## Flow 4: Manage Vault

```mermaid
flowchart TD
    A["Vault Tab"] --> B{"Action"}
    B -->|"Browse"| C["Scroll memory cards"]
    B -->|"Search"| D["Type search query"] --> E["Filtered results"]
    B -->|"Filter"| F["Tap filter chip"] --> E
    C --> G["Tap memory card"]
    E --> G
    G --> H["Memory Detail"]
    H --> I{"Action"}
    I -->|"Favorite"| J["Toggle favorite star"]
    I -->|"Edit tags"| K["Tag editor"]
    I -->|"Related"| L["View linked memories"]
    I -->|"Delete"| M["Confirmation dialog"]
    M -->|"Confirm"| N["Soft delete + undo toast (10s)"]
    M -->|"Cancel"| H
```

---

## Flow 5: Export Encrypted Backup

```mermaid
flowchart TD
    A["Privacy Tab"] --> B["Tap 'Export encrypted backup'"]
    B --> C["Set backup password"]
    C --> D["Confirm password"]
    D --> E["Encrypting... (progress)"]
    E --> F["Backup complete"]
    F --> G{"Action"}
    G -->|"Share"| H["System share sheet"]
    G -->|"Done"| A
```

**Security**: Password-derived key via KDF. Per-backup salt and nonce. AES-256-GCM authenticated encryption.

---

## Flow 6: Import Backup

```mermaid
flowchart TD
    A["Privacy Tab"] --> B["Tap 'Import backup'"]
    B --> C["File picker (.pensieve)"]
    C --> D["Enter backup password"]
    D --> E{"Decrypt"}
    E -->|"Success"| F["Import preview: N memories from date"]
    E -->|"Wrong password"| G["Error: Incorrect password"] --> D
    E -->|"Corrupt file"| H["Error: File couldn't be opened"] --> C
    F --> I{"User choice"}
    I -->|"Import all"| J["Importing... (progress)"]
    J --> K["Import complete"]
    I -->|"Cancel"| A
```

---

## Flow 7: Delete All Data

```mermaid
flowchart TD
    A["Privacy Tab"] --> B["Tap 'Delete all memories'"]
    B --> C["Warning: 'This will permanently delete all memories from your device.'"]
    C --> D["Require vault passcode/biometric"]
    D --> E{"Authenticated?"}
    E -->|"Yes"| F["Type 'DELETE' to confirm"]
    F --> G["Deleting..."]
    G --> H["All memories deleted"]
    E -->|"No"| A
```

**Design principle**: Maximum friction for destructive actions. Three-step confirmation.

---

## Flow 8: App Resume / Vault Unlock

```mermaid
flowchart TD
    A["App goes to background"] --> B["Auto-lock timer starts"]
    B --> C{"Timer expired?"}
    C -->|"Yes"| D["Vault locked"]
    C -->|"No"| E["Resume without lock"]
    D --> F["Unlock screen"]
    F --> G{"Auth method"}
    G -->|"Biometric"| H["Face ID / Fingerprint"]
    G -->|"Passcode"| I["Enter passcode"]
    H -->|"Success"| J["Resume at last screen"]
    H -->|"Fail"| I
    I -->|"Success"| J
    I -->|"Fail 5x"| K["Cool-down period (30s)"]
```

---

## Flow 9: Conversation View

```mermaid
flowchart TD
    A["Talk Tab"] --> B["Speak"]
    B --> C["AI replies"]
    C --> D{"Continue?"}
    D -->|"Continue talking"| B
    D -->|"Save this moment"| E["Save current exchange"]
    D -->|"End conversation"| F["What I'll Remember preview"]
    F --> G{"Review cards"}
    G -->|"Save all"| H["All cards saved"]
    G -->|"Edit card"| I["Edit title/tags"] --> G
    G -->|"Discard card"| J["Remove card"] --> G
    G -->|"Discard all"| K["Return to Idle"]
```
