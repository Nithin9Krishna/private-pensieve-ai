// PrivacyStatusPill.swift
// Private Pensieve AI — iOS
// Reusable privacy/offline status badge

import SwiftUI

struct PrivacyStatusPill: View {
    let text: String
    var style: PillStyle = .privacy

    enum PillStyle {
        case privacy
        case offline
        case neutral

        var textColor: Color {
            switch self {
            case .privacy: return .pensieveAccentTeal
            case .offline: return .pensieveAccentBlue
            case .neutral: return .pensieveTextSecondary
            }
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: style == .privacy ? "lock.shield.fill" : "wifi.slash")
                .font(.system(size: 10))
            Text(text)
                .font(.caption)
        }
        .foregroundColor(style.textColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.pensieveSurfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }
}

// MARK: - MemoryCardView

struct MemoryCardView: View {
    let memory: MemoryCard
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(formattedDate)
                        .font(.footnote)
                        .foregroundColor(.pensieveTextMuted)
                    Spacer()
                    if memory.importanceScore >= 7 {
                        ImportanceMarker(importance: memory.importanceScore)
                    }
                }

                Text(memory.title)
                    .font(.headline)
                    .foregroundColor(.pensieveTextPrimary)
                    .lineLimit(1)

                Text(memory.summary)
                    .font(.callout)
                    .foregroundColor(.pensieveTextSecondary)
                    .lineLimit(2)

                // Chips (max 3)
                let allTags = (memory.emotionTags + memory.topicTags).prefix(3)
                if !allTags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(Array(allTags), id: \.self) { tag in
                            MemoryChip(text: tag)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.pensieveSurfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(memory.title). \(memory.summary)")
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: memory.createdAt)
    }
}

// MARK: - MemoryChip

struct MemoryChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundColor(.pensieveTextSecondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.pensieveSurfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - ImportanceMarker

struct ImportanceMarker: View {
    let importance: Int
    var threshold: Int = 7

    var body: some View {
        if importance >= threshold {
            Circle()
                .fill(Color.pensieveAccentAmber)
                .frame(width: 8, height: 8)
                .accessibilityLabel("Important memory")
        }
    }
}

// MARK: - VaultFilterChip

struct VaultFilterChip: View {
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(.footnote)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .pensieveAccentLavender : .pensieveTextSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected
                        ? Color.pensieveAccentViolet.opacity(0.2)
                        : Color.pensieveSurfaceSecondary
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - RecallQuestionCard

struct RecallQuestionCard: View {
    let question: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.pensieveAccentLavender)
                    .frame(width: 28)

                Text(question)
                    .font(.body)
                    .foregroundColor(.pensieveTextPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.pensieveTextMuted)
            }
            .padding(16)
            .background(Color.pensieveSurfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(question)
    }
}

#Preview("Components") {
    VStack(spacing: 16) {
        PrivacyStatusPill(text: "Local-only", style: .privacy)
        PrivacyStatusPill(text: "Offline ready", style: .offline)
        MemoryChip(text: "Hopeful")
        VaultFilterChip(label: "Important", isSelected: true, onTap: {})
        VaultFilterChip(label: "People", isSelected: false, onTap: {})
    }
    .padding()
    .background(Color.pensieveBackground)
    .preferredColorScheme(.dark)
}
