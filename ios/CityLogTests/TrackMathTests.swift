// Copyright © 2026 CityLog. All rights reserved.

import XCTest
@testable import CityLog

final class TrackMathTests: XCTestCase {

    private let bund = Coordinate(lat: 31.2400, lon: 121.4900)

    private func point(_ lat: Double, _ lon: Double) -> TrackPoint {
        TrackPoint(lat: lat, lon: lon, t: Date(timeIntervalSince1970: 0))
    }

    func test_distance_oneThousandthDegreeLatitude_isAbout111Meters() {
        let d = TrackMath.distance(bund, Coordinate(lat: bund.lat + 0.001, lon: bund.lon))
        XCTAssertEqual(d, 111.2, accuracy: 0.5)
    }

    func test_length_emptyOrSinglePoint_isZero() {
        XCTAssertEqual(TrackMath.length(of: []), 0)
        XCTAssertEqual(TrackMath.length(of: [point(31.24, 121.49)]), 0)
    }

    func test_length_sumsSegments() {
        let track = [point(31.240, 121.49), point(31.241, 121.49), point(31.242, 121.49)]
        XCTAssertEqual(TrackMath.length(of: track), 222.4, accuracy: 1)
    }

    func test_shouldAppend_firstPointWithGoodAccuracy_isAccepted() {
        XCTAssertTrue(TrackMath.shouldAppend(bund, accuracy: 10, after: nil))
    }

    func test_shouldAppend_poorOrInvalidAccuracy_isRejected() {
        XCTAssertFalse(TrackMath.shouldAppend(bund, accuracy: 80, after: nil))
        XCTAssertFalse(TrackMath.shouldAppend(bund, accuracy: -1, after: nil))
    }

    func test_shouldAppend_jitterWithinMinStep_isRejected() {
        let near = Coordinate(lat: bund.lat + 0.00002, lon: bund.lon)
        let far = Coordinate(lat: bund.lat + 0.0002, lon: bund.lon)
        XCTAssertFalse(TrackMath.shouldAppend(near, accuracy: 5, after: bund))
        XCTAssertTrue(TrackMath.shouldAppend(far, accuracy: 5, after: bund))
    }

    func test_cellId_samePlaceSameCell_farPlaceDifferentCell() {
        let a = TrackMath.cellId(bund, referenceLat: 31.23)
        let b = TrackMath.cellId(Coordinate(lat: bund.lat + 0.00001, lon: bund.lon), referenceLat: 31.23)
        let c = TrackMath.cellId(Coordinate(lat: bund.lat + 0.01, lon: bund.lon), referenceLat: 31.23)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }

    func test_litCells_revisitingSameStreet_doesNotDoubleCount() {
        let track = [point(31.2400, 121.49), point(31.2410, 121.49), point(31.2420, 121.49)]
        let once = TrackMath.litCells(tracks: [track], referenceLat: 31.23)
        let twice = TrackMath.litCells(tracks: [track, track], referenceLat: 31.23)
        XCTAssertEqual(once, twice)
        XCTAssertEqual(once.count, 3)
    }

    func test_litArea_hundredCells_isOneSquareKm() {
        XCTAssertEqual(TrackMath.litAreaSquareKm(cellCount: 100), 1.0, accuracy: 0.0001)
    }

    func test_arrivedStop_picksNearestWithinRadius_orNil() {
        let text = LocalizedText(zh: "", en: "", ja: "")
        let near = Stop(id: "near", name: text, story: text, coordinate: Coordinate(lat: bund.lat + 0.0002, lon: bund.lon))
        let far = Stop(id: "far", name: text, story: text, coordinate: Coordinate(lat: bund.lat + 0.01, lon: bund.lon))
        XCTAssertEqual(TrackMath.arrivedStop(at: bund, stops: [far, near])?.id, "near")
        XCTAssertNil(TrackMath.arrivedStop(at: bund, stops: [far]))
    }
}

final class CoordinateConverterTests: XCTestCase {

    func test_wgs84ToGcj02_inShanghai_shiftsByHundredsOfMeters() {
        let wgs = Coordinate(lat: 31.2304, lon: 121.4737)
        let gcj = CoordinateConverter.wgs84ToGcj02(wgs)
        let shift = TrackMath.distance(wgs, gcj)
        XCTAssertGreaterThan(shift, 100)
        XCTAssertLessThan(shift, 800)
    }

    func test_wgs84ToGcj02_outsideChina_isUnchanged() {
        let london = Coordinate(lat: 51.5074, lon: -0.1278)
        XCTAssertEqual(CoordinateConverter.wgs84ToGcj02(london), london)
    }

    func test_cityDisplayCoordinate_onlyConvertsForGCJ02Cities() {
        let name = LocalizedText(zh: "", en: "", ja: "")
        let c = Coordinate(lat: 31.2304, lon: 121.4737)
        let mainland = City(id: "a", name: name, center: c, usesGCJ02: true)
        let abroad = City(id: "b", name: name, center: c, usesGCJ02: false)
        XCTAssertNotEqual(mainland.displayCoordinate(c).latitude, c.lat)
        XCTAssertEqual(abroad.displayCoordinate(c).latitude, c.lat)
        XCTAssertEqual(abroad.displayCoordinate(c).longitude, c.lon)
    }
}
