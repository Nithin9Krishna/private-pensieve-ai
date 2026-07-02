// PrivatePensieveApp.swift
// Private Pensieve AI — iOS
// No login. No cloud. No tracking. Memories stay on device.

import SwiftUI

@main
struct PrivatePensieveApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
        }
    }
}
