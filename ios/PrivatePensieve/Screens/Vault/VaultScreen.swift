// VaultScreen.swift
// Private Pensieve AI — iOS
// Memory vault with search, filters, card list, and empty state (Stitch screens 04, 15)

import SwiftUI

struct VaultScreen: View {
    @StateObject private var viewModel = VaultViewModel()
    @State private var selectedMemory: MemoryCard?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pensieveBackground
                    .ignoresSafeArea()

                if viewModel.isEmpty && !viewModel.isLoading {
                    emptyState
                } else {
                    memoryList
                }
            }
            .navigationTitle("Your Vault")
            .searchable(text: $viewModel.searchText, prompt: "Search memories...")
            .onSubmit(of: .search) { viewModel.performSearch() }
            .sheet(item: $selectedMemory) { memory in
                MemoryDetailView(memory: memory, onDelete: {
                    viewModel.deleteMemory(memory.id)
                    selectedMemory = nil
                })
                .presentationDetents([.large])
            }
        }
        .onAppear { viewModel.loadMemories() }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            // Orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.pensieveAccentViolet.opacity(0.5), .pensieveAccentLavender.opacity(0.2), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 60
                    )
                )
                .frame(width: 100, height: 100)

            Text("Your vault is empty")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.pensieveTextPrimary)

            Text("Start talking and your memories\nwill be saved here.")
                .font(.body)
                .foregroundColor(.pensieveTextSecondary)
                .multilineTextAlignment(.center)

            Button(action: {
                // Navigate to Talk tab
            }) {
                Text("Start Talking →")
                    .font(.headline)
                    .foregroundColor(.pensieveBackground)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color.pensieveAccentLavender)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)

            Spacer()
        }
    }

    // MARK: - Memory List

    private var memoryList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Filter chips
                filterChips
                    .padding(.vertical, 8)

                // Memory count
                HStack {
                    Text("\(viewModel.memoryCount) memories")
                        .font(.caption)
                        .foregroundColor(.pensieveTextMuted)
                    Spacer()
                }
                .padding(.horizontal, 16)

                // Memory cards
                ForEach(viewModel.memories) { memory in
                    MemoryCardView(memory: memory) {
                        selectedMemory = memory
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(VaultViewModel.VaultFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        label: filter.rawValue,
                        isSelected: viewModel.activeFilter == filter,
                        onTap: { viewModel.setFilter(filter) }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .pensieveBackground : .pensieveTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.pensieveAccentLavender : Color.pensieveSurfaceSecondary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Memory Card View

struct MemoryCardView: View {
    let memory: MemoryCard
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    Text(memory.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.pensieveTextPrimary)
                        .lineLimit(1)
                    Spacer()
                    if memory.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.pensieveAccentRed)
                    }
                }

                // Summary
                Text(memory.summary)
                    .font(.caption)
                    .foregroundColor(.pensieveTextSecondary)
                    .lineLimit(2)

                // Tags + Date
                HStack {
                    // Tags
                    HStack(spacing: 4) {
                        ForEach(allTags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 10))
                                .foregroundColor(.pensieveAccentLavender)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.pensieveAccentLavender.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }

                    Spacer()

                    // Date
                    Text(memory.createdAt, style: .date)
                        .font(.system(size: 10))
                        .foregroundColor(.pensieveTextMuted)
                }
            }
            .padding(14)
            .background(Color.pensieveSurfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var allTags: [String] {
        memory.emotionTags + memory.topicTags + memory.peopleTags + memory.goalTags
    }
}

#Preview {
    VaultScreen()
        .preferredColorScheme(.dark)
}
