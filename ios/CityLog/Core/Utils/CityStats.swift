// Copyright © 2026 CityLog. All rights reserved.

import Foundation

/// 一个家庭在一座城市里的累计数据。
struct CityStats: Equatable {
    let outingCount: Int
    let distanceMeters: Double
    let litCellCount: Int
    /// 每个镜头用过几次（按主题出门才计入）。
    let lensCounts: [Lens: Int]
    let walkedThemeIds: Set<String>

    static func make(outings: [Outing], city: City, themes: [Theme]) -> CityStats {
        let mine = outings.filter { $0.cityId == city.id }
        let themeById = Dictionary(uniqueKeysWithValues: themes.map { ($0.id, $0) })
        var lensCounts: [Lens: Int] = [:]
        for outing in mine {
            guard let id = outing.themeId, let theme = themeById[id] else { continue }
            lensCounts[theme.lens, default: 0] += 1
        }
        return CityStats(
            outingCount: mine.count,
            distanceMeters: mine.reduce(0) { $0 + $1.distanceMeters },
            litCellCount: TrackMath.litCells(tracks: mine.map(\.track), referenceLat: city.center.lat).count,
            lensCounts: lensCounts,
            walkedThemeIds: Set(mine.compactMap(\.themeId))
        )
    }
}
