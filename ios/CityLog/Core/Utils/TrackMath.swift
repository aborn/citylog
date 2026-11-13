// Copyright © 2026 CityLog. All rights reserved.

import Foundation

/// 轨迹相关的纯计算：距离、采样过滤、点亮格子、到站判断。
enum TrackMath {
    static let earthRadiusMeters = 6_371_000.0
    /// 定位精度差于这个值的点丢弃。
    static let maxAccuracyMeters = 50.0
    /// 离上一个点不足这个距离的点丢弃，避免原地抖动拉长里程。
    static let minStepMeters = 8.0
    /// 「点亮」的格子边长。
    static let cellMeters = 100.0
    /// 走到离站点这么近算到站。
    static let stopRadiusMeters = 60.0
    private static let metersPerDegreeLat = 111_320.0

    static func distance(_ a: Coordinate, _ b: Coordinate) -> Double {
        let dLat = (b.lat - a.lat) * .pi / 180
        let dLon = (b.lon - a.lon) * .pi / 180
        let h = sin(dLat / 2) * sin(dLat / 2)
            + cos(a.lat * .pi / 180) * cos(b.lat * .pi / 180) * sin(dLon / 2) * sin(dLon / 2)
        return 2 * earthRadiusMeters * asin(min(1, sqrt(h)))
    }

    static func length(of track: [TrackPoint]) -> Double {
        guard track.count > 1 else { return 0 }
        return zip(track, track.dropFirst()).reduce(0) { $0 + distance($1.0.coordinate, $1.1.coordinate) }
    }

    /// 新定位点是否值得记入轨迹。
    static func shouldAppend(_ point: Coordinate, accuracy: Double, after last: Coordinate?) -> Bool {
        guard accuracy >= 0, accuracy <= maxAccuracyMeters else { return false }
        guard let last else { return true }
        return distance(last, point) >= minStepMeters
    }

    /// 坐标所在格子的编号。同一城市用同一个参考纬度，保证格子大小一致。
    static func cellId(_ c: Coordinate, referenceLat: Double) -> String {
        let metersPerDegreeLon = metersPerDegreeLat * cos(referenceLat * .pi / 180)
        let row = Int(floor(c.lat * metersPerDegreeLat / cellMeters))
        let col = Int(floor(c.lon * metersPerDegreeLon / cellMeters))
        return "\(row)_\(col)"
    }

    /// 一组轨迹点亮的全部格子。
    static func litCells(tracks: [[TrackPoint]], referenceLat: Double) -> Set<String> {
        var cells = Set<String>()
        for track in tracks {
            for p in track { cells.insert(cellId(p.coordinate, referenceLat: referenceLat)) }
        }
        return cells
    }

    static func litAreaSquareKm(cellCount: Int) -> Double {
        Double(cellCount) * cellMeters * cellMeters / 1_000_000
    }

    /// 离当前位置最近、且在到站半径内的站点。
    static func arrivedStop(at point: Coordinate, stops: [Stop]) -> Stop? {
        stops
            .map { ($0, distance(point, $0.coordinate)) }
            .filter { $0.1 <= stopRadiusMeters }
            .min { $0.1 < $1.1 }?
            .0
    }
}
