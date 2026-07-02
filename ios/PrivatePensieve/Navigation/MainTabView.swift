// MainTabView.swift
// Private Pensieve AI — iOS
// Four tabs only: Talk, Vault, Recall, Privacy

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: PensieveTab = .talk

    var body: some View {
        TabView(selection: $selectedTab) {
            TalkScreen()
                .tabItem {
                    Label(PensieveTab.talk.title, systemImage: PensieveTab.talk.icon)
                }
                .tag(PensieveTab.talk)

            VaultScreen()
                .tabItem {
                    Label(PensieveTab.vault.title, systemImage: PensieveTab.vault.icon)
                }
                .tag(PensieveTab.vault)

            RecallScreen()
                .tabItem {
                    Label(PensieveTab.recall.title, systemImage: PensieveTab.recall.icon)
                }
                .tag(PensieveTab.recall)

            PrivacyScreen()
                .tabItem {
                    Label(PensieveTab.privacy.title, systemImage: PensieveTab.privacy.icon)
                }
                .tag(PensieveTab.privacy)
        }
        .tint(Color.pensieveAccentLavender)
    }
}

enum PensieveTab: String, CaseIterable {
    case talk
    case vault
    case recall
    case privacy

    var title: String {
        switch self {
        case .talk: return "Talk"
        case .vault: return "Vault"
        case .recall: return "Recall"
        case .privacy: return "Privacy"
        }
    }

    var icon: String {
        switch self {
        case .talk: return "mic.fill"
        case .vault: return "lock.shield.fill"
        case .recall: return "brain.head.profile"
        case .privacy: return "eye.slash.fill"
        }
    }
}

#Preview {
    MainTabView()
}
