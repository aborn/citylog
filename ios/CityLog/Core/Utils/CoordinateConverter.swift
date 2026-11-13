// Copyright © 2026 CityLog. All rights reserved.

import Foundation

/// WGS-84 → GCJ-02 坐标转换。
/// 中国大陆的地图底图使用 GCJ-02，直接把 GPS（WGS-84）坐标画上去会偏几百米。
enum CoordinateConverter {
    private static let semiMajorAxis = 6378245.0
    private static let eccentricitySquared = 0.00669342162296594323

    /// 粗略判断是否在中国大陆范围内；范围外不转换。
    static func isInMainlandChina(_ c: Coordinate) -> Bool {
        c.lon >= 72.004 && c.lon <= 137.8347 && c.lat >= 0.8293 && c.lat <= 55.8271
    }

    static func wgs84ToGcj02(_ c: Coordinate) -> Coordinate {
        guard isInMainlandChina(c) else { return c }
        let x = c.lon - 105.0
        let y = c.lat - 35.0
        var dLat = transformLat(x, y)
        var dLon = transformLon(x, y)
        let radLat = c.lat / 180.0 * .pi
        var magic = sin(radLat)
        magic = 1 - eccentricitySquared * magic * magic
        let sqrtMagic = sqrt(magic)
        dLat = (dLat * 180.0) / ((semiMajorAxis * (1 - eccentricitySquared)) / (magic * sqrtMagic) * .pi)
        dLon = (dLon * 180.0) / (semiMajorAxis / sqrtMagic * cos(radLat) * .pi)
        return Coordinate(lat: c.lat + dLat, lon: c.lon + dLon)
    }

    private static func transformLat(_ x: Double, _ y: Double) -> Double {
        var r = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x))
        r += (20.0 * sin(6.0 * x * .pi) + 20.0 * sin(2.0 * x * .pi)) * 2.0 / 3.0
        r += (20.0 * sin(y * .pi) + 40.0 * sin(y / 3.0 * .pi)) * 2.0 / 3.0
        r += (160.0 * sin(y / 12.0 * .pi) + 320.0 * sin(y * .pi / 30.0)) * 2.0 / 3.0
        return r
    }

    private static func transformLon(_ x: Double, _ y: Double) -> Double {
        var r = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x))
        r += (20.0 * sin(6.0 * x * .pi) + 20.0 * sin(2.0 * x * .pi)) * 2.0 / 3.0
        r += (20.0 * sin(x * .pi) + 40.0 * sin(x / 3.0 * .pi)) * 2.0 / 3.0
        r += (150.0 * sin(x / 12.0 * .pi) + 300.0 * sin(x / 30.0 * .pi)) * 2.0 / 3.0
        return r
    }
}
