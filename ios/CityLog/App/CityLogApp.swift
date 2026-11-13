// Copyright © 2026 CityLog. All rights reserved.

import SwiftUI

@main
struct CityLogApp: App {
    @StateObject private var contentStore = ContentStore()
    @StateObject private var outingStore = OutingStore()
    @StateObject private var profileStore = ProfileStore()
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(contentStore)
                .environmentObject(outingStore)
                .environmentObject(profileStore)
                .environmentObject(router)
                .tint(Color.clBrand)
        }
    }
}

/// 一次出门的请求：按主题走，或者自由走走（theme 为 nil）。
struct WalkRequest: Identifiable, Equatable {
    let id = UUID()
    let city: City
    let theme: Theme?
}

/// 跨页面的导航状态：从地图页或备课卡都可以发起出门。
@MainActor
final class AppRouter: ObservableObject {
    @Published var walk: WalkRequest?
    @Published var selectedTab: AppTab = .map
}

enum AppTab: Hashable {
    case map, themes, journal, family
}
