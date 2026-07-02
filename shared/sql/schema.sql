CREATE TABLE IF NOT EXISTS memory_cards (
 memory_id TEXT PRIMARY KEY,
 created_at TEXT NOT NULL,
 updated_at TEXT NOT NULL,
 source_type TEXT NOT NULL,
 source_conversation_id TEXT,
 title TEXT NOT NULL,
 summary TEXT NOT NULL,
 raw_transcript TEXT,
 emotion_tags TEXT,
 topic_tags TEXT,
 people_tags TEXT,
 place_tags TEXT,
 goal_tags TEXT,
 importance_score INTEGER NOT NULL,
 confidence_score REAL NOT NULL,
 is_favorite INTEGER DEFAULT 0,
 is_archived INTEGER DEFAULT 0,
 is_deleted INTEGER DEFAULT 0
);
CREATE TABLE IF NOT EXISTS conversations (
 conversation_id TEXT PRIMARY KEY,
 created_at TEXT NOT NULL,
 user_transcript TEXT NOT NULL,
 ai_reply TEXT,
 source_type TEXT NOT NULL,
 audio_file_path TEXT,
 is_archived INTEGER DEFAULT 0,
 is_deleted INTEGER DEFAULT 0
);
CREATE TABLE IF NOT EXISTS daily_summaries (
 date TEXT PRIMARY KEY,
 summary TEXT NOT NULL,
 top_emotions TEXT,
 top_topics TEXT,
 important_memory_ids TEXT,
 created_at TEXT NOT NULL,
 updated_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS long_term_facts (
 fact_id TEXT PRIMARY KEY,
 fact_type TEXT NOT NULL,
 fact_text TEXT NOT NULL,
 confidence_score REAL NOT NULL,
 source_memory_ids TEXT,
 created_at TEXT NOT NULL,
 updated_at TEXT NOT NULL,
 is_deleted INTEGER DEFAULT 0
);
CREATE TABLE IF NOT EXISTS memory_edges (
 edge_id TEXT PRIMARY KEY,
 from_id TEXT NOT NULL,
 to_id TEXT NOT NULL,
 edge_type TEXT NOT NULL,
 weight REAL NOT NULL,
 created_at TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_memory_created_at ON memory_cards(created_at);
CREATE INDEX IF NOT EXISTS idx_memory_importance ON memory_cards(importance_score);
CREATE INDEX IF NOT EXISTS idx_memory_deleted ON memory_cards(is_deleted);
CREATE INDEX IF NOT EXISTS idx_conversation_created_at ON conversations(created_at);
CREATE INDEX IF NOT EXISTS idx_daily_date ON daily_summaries(date);
CREATE INDEX IF NOT EXISTS idx_fact_type ON long_term_facts(fact_type);
