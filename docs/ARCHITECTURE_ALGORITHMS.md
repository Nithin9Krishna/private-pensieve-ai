# Private Pensieve AI — Architecture & Algorithms

## 1. System Architecture Diagram

```mermaid
graph TB
    subgraph User["👤 User"]
        Voice["🎙️ Voice Input"]
        Text["⌨️ Text Input"]
        View["👁️ View Memories"]
    end

    subgraph App["📱 Private Pensieve App"]
        subgraph UI["UI Layer (SwiftUI / Compose)"]
            OnboardingFlow["Onboarding Flow<br/>4 Steps"]
            TalkScreen["Talk Screen<br/>7-State Machine"]
            VaultScreen["Vault Screen<br/>Filters + Cards"]
            RecallScreen["Recall Screen<br/>Ask Anything"]
            PrivacyDash["Privacy Dashboard<br/>Status + Actions"]
        end

        subgraph Logic["Logic Layer"]
            TalkVM["TalkViewModel<br/>State Machine"]
            VaultVM["VaultViewModel<br/>Filter + Search"]
            RecallVM["RecallViewModel<br/>Query Handler"]
            RecallEngine["🧠 RecallEngine<br/>5-Factor Scoring"]
        end

        subgraph Providers["Provider Layer (Swappable)"]
            AIBrain["AIBrainProvider<br/>(Protocol/Interface)"]
            STT["SpeechToTextProvider<br/>(Protocol/Interface)"]
            TTS["TTSProvider<br/>(Protocol/Interface)"]
        end

        subgraph Implementations["Provider Implementations"]
            FakeAI["FakeAIBrain<br/>Deterministic V1"]
            AppleAI["Apple Foundation<br/>Models (V2)"]
            GeminiNano["Gemini Nano<br/>(V2)"]
            AppleSTT["Apple Speech<br/>On-Device"]
            AndroidSTT["Android Speech<br/>Recognizer"]
            AppleTTS["AVSpeech<br/>Synthesizer"]
            AndroidTTS["Android<br/>TextToSpeech"]
        end

        subgraph Data["Data Layer (Vault)"]
            VaultDB["🔒 VaultDatabase<br/>SQLite + WAL"]
            MemoryCardDAO["MemoryCardDAO"]
            ConversationDAO["ConversationDAO"]
            DailySummaryDAO["DailySummaryDAO"]
            LongTermFactDAO["LongTermFactDAO"]
            KeyManager["🔐 VaultKeyManager<br/>Keychain / AndroidKeystore"]
        end
    end

    subgraph Storage["📦 Device Storage"]
        SQLite["SQLite DB<br/>(WAL Mode)"]
        KeyStore["🔑 Hardware Keystore<br/>AES-256"]
        AudioFiles["🎵 Audio Cache<br/>(M4A / WAV)"]
    end

    Voice --> TalkScreen
    Text --> RecallScreen
    View --> VaultScreen

    TalkScreen --> TalkVM
    VaultScreen --> VaultVM
    RecallScreen --> RecallVM
    RecallVM --> RecallEngine

    TalkVM --> AIBrain
    TalkVM --> STT
    TalkVM --> TTS
    RecallEngine --> AIBrain

    AIBrain --> FakeAI
    AIBrain -.-> AppleAI
    AIBrain -.-> GeminiNano
    STT --> AppleSTT
    STT --> AndroidSTT
    TTS --> AppleTTS
    TTS --> AndroidTTS

    TalkVM --> MemoryCardDAO
    TalkVM --> ConversationDAO
    VaultVM --> MemoryCardDAO
    RecallEngine --> MemoryCardDAO

    MemoryCardDAO --> VaultDB
    ConversationDAO --> VaultDB
    DailySummaryDAO --> VaultDB
    LongTermFactDAO --> VaultDB
    VaultDB --> SQLite
    KeyManager --> KeyStore
    TalkVM -.-> AudioFiles

    style VaultDB fill:#1a1a2e,stroke:#9b87f5,color:#fff
    style KeyManager fill:#1a1a2e,stroke:#5eead4,color:#fff
    style RecallEngine fill:#1a1a2e,stroke:#f59e0b,color:#fff
    style FakeAI fill:#2d1b4e,stroke:#9b87f5,color:#fff
```

---

## 2. Data Flow: RAM Pipeline

```mermaid
sequenceDiagram
    participant U as 👤 User
    participant T as 🎙️ TalkScreen
    participant VM as TalkViewModel
    participant R as AudioRecorder
    participant S as SpeechToText
    participant AI as AIBrain
    participant DB as VaultDatabase

    U->>T: Taps "Hold to Speak"
    T->>VM: startRecording()
    VM->>R: startRecording()
    R-->>VM: Recording started

    Note over U,R: 🔴 RECORD Phase

    U->>T: Releases button
    T->>VM: stopRecording()
    VM->>R: stopRecording() → audioURL
    VM->>S: transcribe(audioURL)
    S-->>VM: TranscriptionResult{text, confidence}

    Note over VM,S: 📝 ANALYZE Phase

    VM->>AI: extractMemory(transcript)
    AI-->>VM: List<MemoryCard>
    VM->>AI: generateFriendReply(transcript, cards)
    AI-->>VM: "That sounds important..."

    T->>U: Shows TranscriptReviewView

    U->>T: Taps "Save to Vault"

    Note over VM,DB: 💾 MEMORIZE Phase

    VM->>DB: conversationDAO.insert(conversation)
    VM->>DB: memoryCardDAO.insert(card) × N
    VM->>AI: TTS.speak(friendReply)
    VM-->>T: State = .saved ✅
```

---

## 3. The 4 Core Algorithms

---

### Algorithm 1: RAM Pipeline (Record → Analyze → Memorize)

The RAM pipeline converts raw voice input into structured, searchable memory cards.

```
┌─────────────────────────────────────────────────────────┐
│                    RAM PIPELINE                         │
│                                                         │
│  ┌──────────┐    ┌──────────┐    ┌──────────────────┐  │
│  │  RECORD   │───►│ ANALYZE  │───►│    MEMORIZE      │  │
│  │           │    │          │    │                  │  │
│  │ • Mic on  │    │ • STT    │    │ • Save convo    │  │
│  │ • M4A/WAV │    │ • Extract│    │ • Save cards    │  │
│  │ • Timer   │    │   cards  │    │ • Daily summary │  │
│  │ • Buffer  │    │ • Score  │    │ • LT facts      │  │
│  └──────────┘    └──────────┘    └──────────────────┘  │
│                                                         │
│  Input: Raw audio                                       │
│  Output: MemoryCards + Conversation + DailySummary      │
└─────────────────────────────────────────────────────────┘
```

**Pseudocode:**
```
function RAM(audioBuffer):
    // R — Record
    audioFile = writeToM4A(audioBuffer)
    
    // A — Analyze
    transcript = STT.transcribe(audioFile)
    memoryCards = AI.extractMemory(transcript)
    for each card in memoryCards:
        card.importanceScore = AI.assessImportance(card)
        card.confidenceScore = STT.confidence
        card.emotionTags = AI.detectEmotions(transcript)
        card.topicTags = AI.extractTopics(transcript)
        card.peopleTags = AI.extractPeople(transcript)
    
    // M — Memorize
    conversation = Conversation(transcript, timestamp)
    DB.conversations.insert(conversation)
    for each card in memoryCards:
        card.sourceConversationId = conversation.id
        DB.memoryCards.insert(card)
    
    if endOfDay():
        summary = AI.summarizeDay(todaysCards)
        DB.dailySummaries.upsert(summary)
        longTermFacts = AI.extractFacts(allCards)
        DB.longTermFacts.upsert(longTermFacts)
    
    return memoryCards
```

---

### Algorithm 2: Recall Scoring (5-Factor Weighted Formula)

The recall engine uses a **multi-factor weighted scoring algorithm** to rank memory cards by relevance to a user's question.

```
┌─────────────────────────────────────────────────────────┐
│              RECALL SCORING FORMULA                     │
│                                                         │
│  Score(card, query) =                                   │
│      0.35 × Lexical(card, query)    // text overlap     │
│    + 0.25 × TagMatch(card, query)   // tag intersection │
│    + 0.15 × Recency(card)           // time decay       │
│    + 0.15 × Importance(card)        // [0-10] / 10      │
│    + 0.10 × Confidence(card)        // STT confidence   │
│                                                         │
│  Evidence Threshold = 0.15                              │
│  Top-K = 5 cards max                                    │
│                                                         │
│  If no card passes threshold:                           │
│    → "I don't remember you telling me that yet."        │
└─────────────────────────────────────────────────────────┘
```

**Pseudocode:**
```
function Recall(question, allCards):
    keywords = extractKeywords(question)  // remove stop words
    
    scored = []
    for each card in allCards:
        // Factor 1: Lexical overlap (0.35)
        textMatches = count(keywords ∩ words(card.title + card.summary))
        lexical = textMatches / len(keywords)
        
        // Factor 2: Tag match (0.25)
        allTags = card.emotionTags ∪ topicTags ∪ peopleTags ∪ goalTags
        tagMatches = count(keywords ∩ allTags)
        tagMatch = tagMatches / len(keywords)
        
        // Factor 3: Recency — exponential decay (0.15)
        daysSince = (now - card.createdAt) / 86400
        recency = e^(-daysSince / 10)
        
        // Factor 4: Importance (0.15)
        importance = card.importanceScore / 10
        
        // Factor 5: Confidence (0.10)
        confidence = card.confidenceScore
        
        score = 0.35×lexical + 0.25×tagMatch + 0.15×recency 
              + 0.15×importance + 0.10×confidence
        
        scored.append((card, score))
    
    // Filter and rank
    evidence = scored
        .filter(score >= 0.15)      // evidence threshold
        .sortByDescending(score)
        .take(5)                    // top-K
    
    if evidence.isEmpty():
        return "I don't remember you telling me that yet."
    
    return AI.answerFromEvidence(question, evidence)
```

**Recency Decay Curve:**
```
Score
1.0 ┤ ●
0.8 ┤  ╲
0.6 ┤    ╲
0.5 ┤     ╲                    ← 7 days ≈ 0.50
0.4 ┤      ╲
0.2 ┤        ╲───
0.1 ┤            ╲─────        ← 30 days ≈ 0.05
0.0 ┤                  ╲──────
    └──┬──┬──┬──┬──┬──┬──┬──┬─── Days
       0  3  7  10 14 21 30 60
```

---

### Algorithm 3: Query Classification (Intent Detection)

Before searching, the engine classifies the query to determine the correct response strategy.

```
┌─────────────────────────────────────────────────────────┐
│           QUERY CLASSIFICATION TREE                     │
│                                                         │
│  Input: "What did I say about my career?"               │
│                     │                                   │
│               ┌─────┴─────┐                             │
│               │ Contains   │                            │
│               │ recall     │                            │
│               │ keywords?  │                            │
│               └─────┬─────┘                             │
│              yes/   │   \no                             │
│            ┌───┘    │    └───┐                           │
│            │        │        │                           │
│  ┌─────────┴─┐  ┌──┴──────┐ ┌┴──────────┐             │
│  │ MEMORY    │  │ Contains │ │ GENERAL   │             │
│  │ RECALL    │  │reflect   │ │ FRIEND    │             │
│  │           │  │keywords? │ │           │             │
│  │ → Search  │  └─┬─────┬─┘ │ → Chat    │             │
│  │   vault   │  yes│     │no │   reply   │             │
│  │ → Score   │    │     │   │ → No      │             │
│  │ → Answer  │    │     └──►│   search  │             │
│  └───────────┘    │         └───────────┘             │
│              ┌────┴─────┐                               │
│              │REFLECTION│                               │
│              │          │                               │
│              │→ Aggregate│                              │
│              │  patterns │                              │
│              └──────────┘                               │
└─────────────────────────────────────────────────────────┘
```

| Class | Trigger Keywords | Response Strategy |
|-------|-----------------|-------------------|
| **MEMORY_RECALL** | "what did I", "when did I", "did I say", "remind me", "tell me about" | Search vault → score → evidence-bound answer |
| **REFLECTION** | "pattern", "how often", "usually", "trend", "frequently" | Aggregate multiple cards → trend analysis |
| **GENERAL_FRIEND** | Everything else ("I'm feeling down", "hello") | Warm friend reply, no vault assertions |

---

### Algorithm 4: Memory Tiering (4-Tier Storage Strategy)

Memories move through 4 tiers based on age and importance, optimizing storage and retrieval.

```mermaid
graph LR
    subgraph Tier1["🔥 Active RAM (0-24h)"]
        T1["Full transcripts<br/>All tags<br/>Audio available<br/>Fastest retrieval"]
    end

    subgraph Tier2["📋 Recent (1-7 days)"]
        T2["Summary cards<br/>Tags retained<br/>Audio optional<br/>Fast retrieval"]
    end

    subgraph Tier3["📚 Long-Term (7-30 days)"]
        T3["Compressed cards<br/>Core tags only<br/>Audio deleted<br/>Normal retrieval"]
    end

    subgraph Tier4["🗄️ Archive (30+ days)"]
        T4["LongTermFacts<br/>Distilled truths<br/>No raw text<br/>Slow retrieval"]
    end

    T1 -->|"Daily summary<br/>at midnight"| T2
    T2 -->|"Fact extraction<br/>after 7 days"| T3
    T3 -->|"Compress to<br/>facts after 30d"| T4

    style Tier1 fill:#1e1b4b,stroke:#9b87f5,color:#fff
    style Tier2 fill:#1a1a3e,stroke:#818cf8,color:#fff
    style Tier3 fill:#1a1a2e,stroke:#6366f1,color:#fff
    style Tier4 fill:#111827,stroke:#4f46e5,color:#fff
```

**Transition Rules:**
```
function TierTransition():
    // Tier 1 → Tier 2: End of day
    at midnight:
        todaysCards = DB.memoryCards.where(createdAt = today)
        summary = AI.summarizeDay(todaysCards)
        DB.dailySummaries.upsert(summary)
        deleteAudioOlderThan(24h)  // unless user opted to retain
    
    // Tier 2 → Tier 3: After 7 days
    every 7 days:
        oldCards = DB.memoryCards.where(age > 7d, age <= 30d)
        for each card in oldCards:
            card.stripFullTranscript()   // keep summary only
            card.pruneMinorTags()        // keep top-3 tags only
            DB.memoryCards.update(card)
    
    // Tier 3 → Tier 4: After 30 days
    every 30 days:
        ancientCards = DB.memoryCards.where(age > 30d)
        facts = AI.extractLongTermFacts(ancientCards)
        DB.longTermFacts.upsert(facts)
        // Cards remain searchable but marked as archived
        ancientCards.forEach { it.isArchived = true }
```

---

## 4. Database Schema

```mermaid
erDiagram
    memory_cards ||--o{ conversations : "sourceConversationId"
    daily_summaries ||--o{ memory_cards : "importantMemoryIds"
    long_term_facts ||--o{ memory_cards : "sourceMemoryIds"

    memory_cards {
        TEXT memory_id PK
        TEXT created_at
        TEXT source_conversation_id FK
        TEXT title
        TEXT summary
        TEXT emotion_tags "JSON array"
        TEXT topic_tags "JSON array"
        TEXT people_tags "JSON array"
        TEXT goal_tags "JSON array"
        INTEGER importance_score "0-10"
        REAL confidence_score "0.0-1.0"
        INTEGER is_favorite
        INTEGER is_archived
        INTEGER is_deleted
    }

    conversations {
        TEXT conversation_id PK
        TEXT created_at
        TEXT source_type "voice|text"
        TEXT user_transcript
        TEXT ai_reply
        TEXT audio_file_path
        INTEGER is_archived
        INTEGER is_deleted
    }

    daily_summaries {
        TEXT date PK
        TEXT summary
        TEXT top_emotions "JSON"
        TEXT top_topics "JSON"
        TEXT important_memory_ids "JSON"
    }

    long_term_facts {
        TEXT fact_id PK
        TEXT fact_type "preference|habit|belief|relationship|goal"
        TEXT fact_text
        REAL confidence_score
        TEXT source_memory_ids "JSON"
        INTEGER is_deleted
    }
```

---

## 5. Technology Stack Summary

| Layer | iOS | Android | Shared |
|-------|-----|---------|--------|
| **UI** | SwiftUI | Jetpack Compose | — |
| **State** | `@StateObject` + `ObservableObject` | `ViewModel` + `mutableStateOf` | — |
| **DB** | SQLite3 (C API) | `SQLiteOpenHelper` | Schema identical |
| **Key Store** | Keychain (AES-256) | AndroidKeystore (AES-256-GCM) | — |
| **Audio** | AVAudioEngine (M4A/AAC) | AudioRecord (WAV/PCM) | — |
| **STT** | SFSpeechRecognizer (on-device) | SpeechRecognizer (offline) | — |
| **TTS** | AVSpeechSynthesizer | TextToSpeech | — |
| **AI** | FakeAIBrain / Apple FM (V2) | FakeAIBrain / Gemini Nano (V2) | Protocol-based |
| **Navigation** | TabView + NavigationStack | Scaffold + NavigationBar | 4 tabs |
