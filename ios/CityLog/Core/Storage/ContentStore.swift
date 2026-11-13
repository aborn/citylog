// Copyright © 2026 CityLog. All rights reserved.

import Foundation

/// 城市与主题内容。目前随 App 打包，后续可换成在线更新。
@MainActor
final class ContentStore: ObservableObject {
    static let resourceName = "content"

    @Published private(set) var cities: [City] = []
    @Published private(set) var themes: [Theme] = []

    init(bundle: ContentBundle) {
        cities = bundle.cities
        themes = bundle.themes
    }

    /// 从 App 包里读取内容；读不到时返回空内容，界面显示空态。
    convenience init(mainBundle: Bundle = .main) {
        let loaded = (try? ContentStore.load(from: mainBundle)) ?? ContentBundle(cities: [], themes: [])
        self.init(bundle: loaded)
    }

    static func load(from bundle: Bundle) throws -> ContentBundle {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw AppError.contentMissing
        }
        return try decode(Data(contentsOf: url))
    }

    static func decode(_ data: Data) throws -> ContentBundle {
        try JSONDecoder().decode(ContentBundle.self, from: data)
    }

    func city(id: String) -> City? { cities.first { $0.id == id } }
    func theme(id: String) -> Theme? { themes.first { $0.id == id } }

    func themes(inCity cityId: String, lens: Lens? = nil) -> [Theme] {
        themes.filter { $0.cityId == cityId && (lens == nil || $0.lens == lens) }
    }

    /// 本周末推荐：优先推荐这家人还没走过的主题。
    func featuredTheme(inCity cityId: String, walkedThemeIds: Set<String>) -> Theme? {
        let candidates = themes(inCity: cityId)
        return candidates.first { !walkedThemeIds.contains($0.id) } ?? candidates.first
    }
}
