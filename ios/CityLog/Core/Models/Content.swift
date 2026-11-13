// Copyright © 2026 CityLog. All rights reserved.

import Foundation
import CoreLocation

/// 界面与内容支持的三种语言。
enum AppLanguage: String, CaseIterable, Codable {
    case zh, en, ja

    static var current: AppLanguage {
        let code = Locale.current.language.languageCode?.identifier ?? "en"
        return AppLanguage(rawValue: code) ?? .en
    }

    /// 语音讲解用的 BCP-47 语言代码。
    var speechCode: String {
        switch self {
        case .zh: return "zh-CN"
        case .en: return "en-US"
        case .ja: return "ja-JP"
        }
    }
}

/// 一段三语文本。内容数据全部用它，界面按当前语言取值。
struct LocalizedText: Codable, Equatable, Hashable {
    let zh: String
    let en: String
    let ja: String

    func text(_ language: AppLanguage = .current) -> String {
        switch language {
        case .zh: return zh
        case .en: return en
        case .ja: return ja
        }
    }
}

/// 观察城市的六个镜头。
enum Lens: String, Codable, CaseIterable, Hashable {
    case history, culture, industry, planning, civic, nature
}

/// 孩子的年龄段，决定备课卡的讲法。
enum AgeBand: String, Codable, CaseIterable, Hashable {
    case young, middle, older

    static let youngUpperAge = 6
    static let middleUpperAge = 9

    /// 4–6 岁、6–9 岁、9–12 岁；边界年龄归入较大的一档。
    static func forAge(_ age: Int) -> AgeBand {
        if age < youngUpperAge { return .young }
        if age < middleUpperAge { return .middle }
        return .older
    }
}

/// WGS-84 坐标。内容数据与轨迹一律存 WGS-84，显示时再按城市转换。
struct Coordinate: Codable, Equatable, Hashable {
    let lat: Double
    let lon: Double

    var clLocation: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: lat, longitude: lon) }
}

struct City: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let name: LocalizedText
    let center: Coordinate
    /// 中国大陆的地图底图是 GCJ-02，显示前需要把 WGS-84 坐标转换过去。
    let usesGCJ02: Bool

    /// 把 WGS-84 坐标转换成这座城市地图上应显示的坐标。
    func displayCoordinate(_ coordinate: Coordinate) -> CLLocationCoordinate2D {
        usesGCJ02 ? CoordinateConverter.wgs84ToGcj02(coordinate).clLocation : coordinate.clLocation
    }
}

struct Stop: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let name: LocalizedText
    let story: LocalizedText
    let coordinate: Coordinate
}

/// 一个周末主题，同时也是一张备课卡的全部内容。
struct Theme: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let cityId: String
    let lens: Lens
    let title: LocalizedText
    let area: LocalizedText
    let distanceKm: Double
    let minutes: Int
    /// 键是 AgeBand.rawValue。
    let oneLiner: [String: LocalizedText]
    let question: [String: LocalizedText]
    let stops: [Stop]
    /// 内容是否已经对照史料逐条核对。未核对的在界面上明示。
    let verified: Bool

    func oneLiner(for band: AgeBand) -> LocalizedText? { oneLiner[band.rawValue] }
    func question(for band: AgeBand) -> LocalizedText? { question[band.rawValue] }
}

struct ContentBundle: Codable, Equatable {
    let cities: [City]
    let themes: [Theme]
}
