// Copyright © 2026 CityLog. All rights reserved.

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var outingStore: OutingStore
    @EnvironmentObject private var profileStore: ProfileStore

    var body: some View {
        let s = AppStrings.current
        TabView(selection: $router.selectedTab) {
            NavigationStack { MapHomeView() }
                .tabItem { Label(s.tabMap, systemImage: "map") }
                .tag(AppTab.map)
            NavigationStack { ThemeListView() }
                .tabItem { Label(s.tabThemes, systemImage: "signpost.right") }
                .tag(AppTab.themes)
            NavigationStack { JournalListView() }
                .tabItem { Label(s.tabJournal, systemImage: "book.closed") }
                .tag(AppTab.journal)
            NavigationStack { FamilyView() }
                .tabItem { Label(s.tabFamily, systemImage: "house") }
                .tag(AppTab.family)
        }
        .fullScreenCover(item: $router.walk) { request in
            WalkView(
                viewModel: WalkViewModel(city: request.city, theme: request.theme),
                onFinished: { router.selectedTab = .journal }
            )
            .environmentObject(outingStore)
            .environmentObject(profileStore)
        }
    }
}
