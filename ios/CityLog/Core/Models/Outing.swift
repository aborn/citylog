// Copyright © 2026 CityLog. All rights reserved.

import Foundation

/// 轨迹上的一个点（WGS-84）。
struct TrackPoint: Codable, Equatable {
    let lat: Double
    let lon: Double
    let t: Date

    var coordinate: Coordinate { Coordinate(lat: lat, lon: lon) }
}

/// 路上「拍一拍」留下的一条问答。
struct SnapNote: Codable, Identifiable, Equatable {
    let id: UUID
    let question: String
    let answer: String
    /// 照片文件名（存在出门记录目录下），没有照片时为 nil。
    let photoFile: String?
    let date: Date
}

/// 一次出门的完整记录，也就是一页日志。
struct Outing: Codable, Identifiable, Equatable {
    let id: UUID
    let cityId: String
    let themeId: String?
    var title: String
    let startedAt: Date
    var endedAt: Date
    var track: [TrackPoint]
    var distanceMeters: Double
    var visitedStopIds: [String]
    var childQuote: String
    var snaps: [SnapNote]
}

/// 家庭档案。孩子没有账号，只留昵称和出生年份。
struct FamilyProfile: Codable, Equatable {
    var childNickname: String
    var childBirthYear: Int
    var cityId: String

    static let defaultCityId = "shanghai"
    static let defaultChildAge = 6

    static func makeDefault(currentYear: Int) -> FamilyProfile {
        FamilyProfile(childNickname: "", childBirthYear: currentYear - defaultChildAge, cityId: defaultCityId)
    }

    func childAge(currentYear: Int) -> Int { max(0, currentYear - childBirthYear) }
    func ageBand(currentYear: Int) -> AgeBand { AgeBand.forAge(childAge(currentYear: currentYear)) }
}
