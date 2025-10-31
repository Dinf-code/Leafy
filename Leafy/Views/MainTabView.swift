//
//  MainTabView.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-05.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            // DASHBOARD TAB
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }
            .tag(0)

            // MY PLANTS TAB
            NavigationStack {
                MyPlantsView()
            }
            .tabItem {
                Label("My Plants", systemImage: "leaf.fill")
            }
            .tag(1)

            // CALENDAR TAB
            NavigationStack {
                CalendarView()
            }
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }
            .tag(2)

            // SETTINGS TAB
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(3)
        }
        .tint(LeafyTheme.Colors.accent)
        .background(LeafyTheme.Colors.background.ignoresSafeArea())
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
}
