// Copyright © 2026 CityLog. All rights reserved.

import Foundation

/// 一次出门的状态：轨迹、里程、到过的站、孩子的话、拍一拍问答。
@MainActor
final class WalkViewModel: ObservableObject {
    let city: City
    let theme: Theme?
    let outingId = UUID()
    let startedAt: Date

    @Published private(set) var track: [TrackPoint] = []
    @Published private(set) var distanceMeters: Double = 0
    @Published private(set) var visitedStopIds: [String] = []
    @Published private(set) var snaps: [SnapNote] = []
    @Published var childQuote: String = ""

    init(city: City, theme: Theme?, startedAt: Date = Date()) {
        self.city = city
        self.theme = theme
        self.startedAt = startedAt
    }

    var stops: [Stop] { theme?.stops ?? [] }

    /// 界面上要讲的站：刚到的那一站；还没到任何新站时是下一个没去过的站。
    var currentStop: Stop? {
        if let last = track.last, let arrived = TrackMath.arrivedStop(at: last.coordinate, stops: stops) {
            return arrived
        }
        return stops.first { !visitedStopIds.contains($0.id) } ?? stops.last
    }

    /// 有没有值得存成日志的内容。
    var hasContent: Bool {
        track.count > 1 || !snaps.isEmpty || !childQuote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 处理一个新定位点：过滤抖动、累加里程、判断到站。
    func ingest(coordinate: Coordinate, accuracy: Double, at time: Date) {
        guard TrackMath.shouldAppend(coordinate, accuracy: accuracy, after: track.last?.coordinate) else { return }
        if let last = track.last {
            distanceMeters += TrackMath.distance(last.coordinate, coordinate)
        }
        track.append(TrackPoint(lat: coordinate.lat, lon: coordinate.lon, t: time))
        if let arrived = TrackMath.arrivedStop(at: coordinate, stops: stops), !visitedStopIds.contains(arrived.id) {
            visitedStopIds.append(arrived.id)
        }
    }

    func addSnap(question: String, answer: String, photoFile: String?, at time: Date = Date()) {
        snaps.append(SnapNote(id: UUID(), question: question, answer: answer, photoFile: photoFile, date: time))
    }

    func makeOuting(endedAt: Date = Date(), freeWalkTitle: String, language: AppLanguage = .current) -> Outing {
        Outing(
            id: outingId,
            cityId: city.id,
            themeId: theme?.id,
            title: theme?.title.text(language) ?? freeWalkTitle,
            startedAt: startedAt,
            endedAt: endedAt,
            track: track,
            distanceMeters: distanceMeters,
            visitedStopIds: visitedStopIds,
            childQuote: childQuote.trimmingCharacters(in: .whitespacesAndNewlines),
            snaps: snaps
        )
    }
}
