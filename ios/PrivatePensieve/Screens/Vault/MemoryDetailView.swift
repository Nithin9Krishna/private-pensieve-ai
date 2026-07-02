// MemoryDetailView.swift
// Private Pensieve AI — iOS
// Full memory detail: AI insight, transcript, tags, actions (Stitch screen 13)

import SwiftUI

struct MemoryDetailView: View {
    let memory: MemoryCard
    let onDelete: () -> Void

    @State private var showDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pensieveBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title & date
                        VStack(alignment: .leading, spacing: 4) {
                            Text(memory.title)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.pensieveTextPrimary)

                            Text(memory.createdAt, style: .date)
                                .font(.caption)
                                .foregroundColor(.pensieveTextMuted)
                        }

                        // AI Insight card
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .font(.caption)
                                    .foregroundColor(.pensieveAccentLavender)
                                Text("AI Insight Summary")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.pensieveAccentLavender)
                            }
                            Text(memory.summary)
                                .font(.subheadline)
                                .foregroundColor(.pensieveTextPrimary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.pensieveSurfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Tags section
                        VStack(alignment: .leading, spacing: 12) {
                            tagSection("Emotions", tags: memory.emotionTags, color: .pensieveAccentAmber)
                            tagSection("Topics", tags: memory.topicTags, color: .pensieveAccentBlue)
                            tagSection("People", tags: memory.peopleTags, color: .pensieveAccentTeal)
                            tagSection("Goals", tags: memory.goalTags, color: .pensieveAccentLavender)
                        }

                        // Scores
                        HStack(spacing: 24) {
                            ScoreBadge(label: "Importance", value: "\(memory.importanceScore)/10",
                                       color: memory.importanceScore >= 7 ? .pensieveAccentAmber : .pensieveTextMuted)
                            ScoreBadge(label: "Confidence", value: String(format: "%.0f%%", memory.confidenceScore * 100),
                                       color: .pensieveAccentTeal)
                        }

                        Divider().background(Color.pensieveBorder)

                        // Actions
                        VStack(spacing: 12) {
                            Button(action: { showDeleteConfirmation = true }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete Memory")
                                }
                                .font(.subheadline)
                                .foregroundColor(.pensieveAccentRed)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.pensieveAccentRed.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Memory Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.pensieveTextMuted)
                    }
                }
            }
            .alert("Delete Memory?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    onDelete()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This memory will be permanently removed from your vault.")
            }
        }
    }

    @ViewBuilder
    private func tagSection(_ title: String, tags: [String], color: Color) -> some View {
        if !tags.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.pensieveTextMuted)

                FlowLayout(spacing: 6) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 11))
                            .foregroundColor(color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(color.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
}

// MARK: - Score Badge

struct ScoreBadge: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.pensieveTextMuted)
        }
    }
}

// MARK: - Flow Layout (simple horizontal wrap)

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}

#Preview {
    MemoryDetailView(
        memory: MemoryCard(
            id: "test-1",
            createdAt: Date(),
            updatedAt: Date(),
            sourceConversationId: "conv-1",
            title: "Coffee with Maya at the lake",
            summary: "Had a meaningful conversation about career change. Feeling more confident after talking through the options.",
            emotionTags: ["calm", "hopeful"],
            topicTags: ["career", "decisions"],
            peopleTags: ["Maya"],
            placeTags: ["lake"],
            goalTags: ["career change"],
            importanceScore: 8,
            confidenceScore: 0.92,
            duplicateGroupId: nil,
            isFavorite: true,
            isSensitive: false,
            isArchived: false,
            isDeleted: false
        ),
        onDelete: {}
    )
    .preferredColorScheme(.dark)
}
