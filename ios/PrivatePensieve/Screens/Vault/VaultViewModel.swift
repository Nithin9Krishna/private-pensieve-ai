// VaultViewModel.swift
// Private Pensieve AI — iOS
// Manages memory card list, filtering, search, and stats.

import SwiftUI
import Combine

@MainActor
final class VaultViewModel: ObservableObject {

    // MARK: - Published State

    @Published var memories: [MemoryCard] = []
    @Published var activeFilter: VaultFilter = .all
    @Published var searchText: String = ""
    @Published var isLoading = false
    @Published var memoryCount: Int = 0

    enum VaultFilter: String, CaseIterable {
        case all = "All"
        case important = "Important"
        case goals = "Goals"
        case people = "People"
        case favorites = "Favorites"
    }

    private let dao: MemoryCardDAO

    init(dao: MemoryCardDAO = MemoryCardDAO()) {
        self.dao = dao
    }

    // MARK: - Load

    func loadMemories() {
        isLoading = true
        do {
            let filter = buildFilter()
            memories = try dao.fetch(filter: filter)
            memoryCount = try dao.activeCount()
        } catch {
            memories = []
        }
        isLoading = false
    }

    // MARK: - Filter

    func setFilter(_ filter: VaultFilter) {
        activeFilter = filter
        loadMemories()
    }

    func performSearch() {
        loadMemories()
    }

    private func buildFilter() -> MemoryFilter {
        var filter = MemoryFilter()
        filter.searchText = searchText.isEmpty ? nil : searchText

        switch activeFilter {
        case .all:
            break
        case .important:
            filter.minImportance = 7
        case .goals:
            filter.tag = "goal"
        case .people:
            filter.tag = "people"
        case .favorites:
            filter.favoritesOnly = true
        }

        return filter
    }

    // MARK: - Actions

    func toggleFavorite(_ id: String) {
        try? dao.toggleFavorite(id)
        loadMemories()
    }

    func deleteMemory(_ id: String) {
        try? dao.softDelete(id)
        loadMemories()
    }

    /// Whether the vault is empty (no memories at all).
    var isEmpty: Bool { memories.isEmpty && searchText.isEmpty && activeFilter == .all }
}
