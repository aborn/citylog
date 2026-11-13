// Copyright © 2026 CityLog. All rights reserved.

import XCTest
@testable import CityLog

@MainActor
final class WalkAndStoreTests: XCTestCase {

    private let text = LocalizedText(zh: "中", en: "en", ja: "日")
    private let t0 = Date(timeIntervalSince1970: 1_800_000_000)
    private var tempDir: URL!

    override func setUp() async throws {
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: tempDir)
    }

    private var city: City {
        City(id: "osaka", name: text, center: Coordinate(lat: 34.6937, lon: 135.5023), usesGCJ02: false)
    }

    private func theme(stops: [Stop]) -> Theme {
        Theme(id: "t1", cityId: "osaka", lens: .industry, title: text, area: text, distanceKm: 1, minutes: 60,
              oneLiner: [:], question: [:], stops: stops, verified: false)
    }

    private func stop(_ id: String, lat: Double) -> Stop {
        Stop(id: id, name: text, story: text, coordinate: Coordinate(lat: lat, lon: 135.5))
    }

    // MARK: - WalkViewModel

    func test_ingest_accumulatesDistance_andDropsBadPoints() {
        let vm = WalkViewModel(city: city, theme: nil, startedAt: t0)
        vm.ingest(coordinate: Coordinate(lat: 34.6900, lon: 135.5), accuracy: 5, at: t0)
        vm.ingest(coordinate: Coordinate(lat: 34.6910, lon: 135.5), accuracy: 500, at: t0)
        vm.ingest(coordinate: Coordinate(lat: 34.69001, lon: 135.5), accuracy: 5, at: t0)
        vm.ingest(coordinate: Coordinate(lat: 34.6910, lon: 135.5), accuracy: 5, at: t0)
        XCTAssertEqual(vm.track.count, 2)
        XCTAssertEqual(vm.distanceMeters, 111.2, accuracy: 1)
    }

    func test_ingest_marksStopVisitedOnce_andAdvancesCurrentStop() {
        let a = stop("a", lat: 34.6900)
        let b = stop("b", lat: 34.7000)
        let vm = WalkViewModel(city: city, theme: theme(stops: [a, b]), startedAt: t0)
        XCTAssertEqual(vm.currentStop?.id, "a")
        vm.ingest(coordinate: Coordinate(lat: 34.6901, lon: 135.5), accuracy: 5, at: t0)
        vm.ingest(coordinate: Coordinate(lat: 34.6903, lon: 135.5), accuracy: 5, at: t0)
        XCTAssertEqual(vm.visitedStopIds, ["a"])
        XCTAssertEqual(vm.currentStop?.id, "a")
        vm.ingest(coordinate: Coordinate(lat: 34.6950, lon: 135.5), accuracy: 5, at: t0)
        XCTAssertEqual(vm.currentStop?.id, "b")
    }

    func test_hasContent_falseUntilSomethingRecorded() {
        let vm = WalkViewModel(city: city, theme: nil, startedAt: t0)
        XCTAssertFalse(vm.hasContent)
        vm.childQuote = "   "
        XCTAssertFalse(vm.hasContent)
        vm.childQuote = "船可以送米"
        XCTAssertTrue(vm.hasContent)
    }

    func test_makeOuting_usesThemeTitleInLanguage_orFreeWalkTitle() {
        let themed = WalkViewModel(city: city, theme: theme(stops: []), startedAt: t0)
        themed.childQuote = "  船可以送米  "
        themed.addSnap(question: "q", answer: "a", photoFile: nil, at: t0)
        let outing = themed.makeOuting(endedAt: t0.addingTimeInterval(60), freeWalkTitle: "自由走走", language: .ja)
        XCTAssertEqual(outing.title, "日")
        XCTAssertEqual(outing.themeId, "t1")
        XCTAssertEqual(outing.childQuote, "船可以送米")
        XCTAssertEqual(outing.snaps.count, 1)
        XCTAssertEqual(outing.id, themed.outingId)

        let free = WalkViewModel(city: city, theme: nil, startedAt: t0)
        XCTAssertEqual(free.makeOuting(freeWalkTitle: "自由走走").title, "自由走走")
        XCTAssertNil(free.makeOuting(freeWalkTitle: "自由走走").themeId)
    }

    // MARK: - OutingStore

    private func outing(_ title: String, startedAt: Date, cityId: String = "osaka", themeId: String? = nil,
                        track: [TrackPoint] = [], distance: Double = 0) -> Outing {
        Outing(id: UUID(), cityId: cityId, themeId: themeId, title: title, startedAt: startedAt, endedAt: startedAt,
               track: track, distanceMeters: distance, visitedStopIds: [], childQuote: "", snaps: [])
    }

    func test_outingStore_saveReloadDelete_roundTrip() throws {
        let store = OutingStore(directory: tempDir)
        XCTAssertTrue(store.outings.isEmpty)
        let older = outing("older", startedAt: t0)
        let newer = outing("newer", startedAt: t0.addingTimeInterval(86_400))
        try store.save(older)
        try store.save(newer)

        let reopened = OutingStore(directory: tempDir)
        XCTAssertEqual(reopened.outings.map(\.title), ["newer", "older"])
        XCTAssertEqual(reopened.outings.last, older)

        try reopened.delete(older)
        XCTAssertEqual(OutingStore(directory: tempDir).outings.map(\.title), ["newer"])
    }

    func test_outingStore_saveSameId_updatesInPlace() throws {
        let store = OutingStore(directory: tempDir)
        var item = outing("walk", startedAt: t0)
        try store.save(item)
        item.childQuote = "工厂要住在河边"
        try store.save(item)
        XCTAssertEqual(store.outings.count, 1)
        XCTAssertEqual(store.outings.first?.childQuote, "工厂要住在河边")
    }

    func test_outingStore_photoIsStoredAndRemovedWithOuting() throws {
        let store = OutingStore(directory: tempDir)
        let item = outing("walk", startedAt: t0)
        try store.save(item)
        let name = try store.savePhoto(Data([1, 2, 3]), outingId: item.id)
        let url = store.photoURL(name, outingId: item.id)
        XCTAssertEqual(try Data(contentsOf: url), Data([1, 2, 3]))
        try store.delete(item)
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
    }

    func test_outingStore_skipsCorruptFiles() throws {
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        try Data("not json".utf8).write(to: tempDir.appendingPathComponent("broken.json"))
        XCTAssertTrue(OutingStore(directory: tempDir).outings.isEmpty)
    }

    // MARK: - CityStats

    func test_cityStats_countsOnlyThisCity_andLensUsage() {
        let p = { (lat: Double) in TrackPoint(lat: lat, lon: 135.5, t: self.t0) }
        let outings = [
            outing("a", startedAt: t0, themeId: "t1", track: [p(34.690), p(34.691)], distance: 111),
            outing("b", startedAt: t0, themeId: "t1", track: [p(34.690), p(34.691)], distance: 111),
            outing("free", startedAt: t0, track: [p(34.700)], distance: 50),
            outing("other", startedAt: t0, cityId: "shanghai", themeId: "t1", distance: 999)
        ]
        let stats = CityStats.make(outings: outings, city: city, themes: [theme(stops: [])])
        XCTAssertEqual(stats.outingCount, 3)
        XCTAssertEqual(stats.distanceMeters, 272, accuracy: 0.001)
        XCTAssertEqual(stats.litCellCount, 3)
        XCTAssertEqual(stats.lensCounts, [.industry: 2])
        XCTAssertEqual(stats.walkedThemeIds, ["t1"])
    }

    // MARK: - ProfileStore

    func test_profileStore_persistsProfileAndAIConfig() throws {
        let suite = "citylog.tests." + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let secrets = InMemorySecretStore()

        let first = ProfileStore(defaults: defaults, secrets: secrets)
        XCTAssertEqual(first.profile.cityId, FamilyProfile.defaultCityId)
        XCTAssertFalse(first.aiConfig.isComplete)
        first.profile.cityId = "osaka"
        first.profile.childNickname = "小满"
        first.updateAIConfig(AIConfig(baseURL: "https://example.com/v1", model: "m", apiKey: "k"))

        let second = ProfileStore(defaults: defaults, secrets: secrets)
        XCTAssertEqual(second.profile.cityId, "osaka")
        XCTAssertEqual(second.profile.childNickname, "小满")
        XCTAssertTrue(second.aiConfig.isComplete)
        XCTAssertNil(defaults.string(forKey: "citylog.ai.apiKey"), "密钥不应写入 UserDefaults")
    }
}
