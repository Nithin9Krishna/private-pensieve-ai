// VaultScreen.swift
// Private Pensieve AI — iOS
// Memory vault: calm collection of memory fragments

import SwiftUI

struct VaultScreen: View {
    @State private var selectedFilter: VaultFilter = .all
    @State private var searchText = ""
    @State private var memories: [MemoryCard] = [] // Will be populated from VaultRepository

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pensieveBackground
                    .ignoresSafeArea()

                if memories.isEmpty {
                    emptyState
                } else {
                    memoryList
                }
            }
            .navigationTitle("Your Vault")
            .searchable(text: $searchText, prompt: "Search memories")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "lock.shield")
                .font(.system(size: 48))
                .foregroundColor(.pensieveTextMuted)

            Text("Your vault is waiting.")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.pensieveTextPrimary)

            Text("The moments you choose to save will appear here.")
                .font(.body)
                .foregroundColor(.pensieveTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: {
                // TODO: Navigate to Talk tab
            }) {
                Text("Talk to me")
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

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(VaultFilter.allCases, id: \.self) { filter in
                    VaultFilterChip(
                        label: filter.displayName,
                        isSelected: selectedFilter == filter,
                        onTap: { selectedFilter = filter }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var memoryList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                filterChips
                    .padding(.vertical, 8)

                ForEach(memories) { memory in
                    MemoryCardView(memory: memory) {
                        // TODO: Navigate to memory detail
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

enum VaultFilter: String, CaseIterable {
    case all, important, ideas, people, goals, feelings, thisWeek, thisMonth

    var displayName: String {
        switch self {
        case .all: return "All"
        case .important: return "Important"
        case .ideas: return "Ideas"
        case .people: return "People"
        case .goals: return "Goals"
        case .feelings: return "Feelings"
        case .thisWeek: return "This week"
        case .thisMonth: return "This month"
        }
    }
}

#Preview {
    VaultScreen()
        .preferredColorScheme(.dark)
}
