// Copyright © 2026 CityLog. All rights reserved.

import XCTest
@testable import CityLog

/// 随 App 打包的内容文件必须完整：每个主题三种年龄、三种语言都有文案。
@MainActor
final class ContentTests: XCTestCase {

    private func loadBundled() throws -> ContentBundle {
        try ContentStore.load(from: .main)
    }

    func test_bundledContent_hasShanghaiAndOsaka() throws {
        let content = try loadBundled()
        XCTAssertEqual(Set(content.cities.map(\.id)), ["shanghai", "osaka"])
        XCTAssertEqual(content.cities.first { $0.id == "shanghai" }?.usesGCJ02, true)
        XCTAssertEqual(content.cities.first { $0.id == "osaka" }?.usesGCJ02, false)
    }

    func test_bundledContent_everyCityHasThemes() throws {
        let content = try loadBundled()
        for city in content.cities {
            XCTAssertFalse(content.themes.filter { $0.cityId == city.id }.isEmpty, "\(city.id) 没有主题")
        }
    }

    func test_bundledContent_everyThemeIsCompleteInAllLanguagesAndAges() throws {
        let content = try loadBundled()
        for theme in content.themes {
            XCTAssertFalse(theme.stops.isEmpty, theme.id)
            for band in AgeBand.allCases {
                for language in AppLanguage.allCases {
                    XCTAssertFalse(theme.oneLiner(for: band)?.text(language).isEmpty ?? true, "\(theme.id) \(band) \(language)")
                    XCTAssertFalse(theme.question(for: band)?.text(language).isEmpty ?? true, "\(theme.id) \(band) \(language)")
                }
            }
            for stop in theme.stops {
                for language in AppLanguage.allCases {
                    XCTAssertFalse(stop.name.text(language).isEmpty, stop.id)
                    XCTAssertFalse(stop.story.text(language).isEmpty, stop.id)
                }
            }
        }
    }

    func test_bundledContent_stopsAreNearTheirCity() throws {
        let content = try loadBundled()
        let maxDistanceMeters = 40_000.0
        for theme in content.themes {
            let city = try XCTUnwrap(content.cities.first { $0.id == theme.cityId })
            for stop in theme.stops {
                XCTAssertLessThan(TrackMath.distance(city.center, stop.coordinate), maxDistanceMeters, stop.id)
            }
        }
    }

    func test_bundledContent_idsAreUnique() throws {
        let content = try loadBundled()
        let themeIds = content.themes.map(\.id)
        let stopIds = content.themes.flatMap { $0.stops.map(\.id) }
        XCTAssertEqual(themeIds.count, Set(themeIds).count)
        XCTAssertEqual(stopIds.count, Set(stopIds).count)
    }

    func test_featuredTheme_prefersThemeNotYetWalked() throws {
        let store = ContentStore(bundle: try loadBundled())
        let all = store.themes(inCity: "osaka")
        XCTAssertGreaterThan(all.count, 1)
        XCTAssertEqual(store.featuredTheme(inCity: "osaka", walkedThemeIds: [])?.id, all[0].id)
        XCTAssertEqual(store.featuredTheme(inCity: "osaka", walkedThemeIds: [all[0].id])?.id, all[1].id)
        XCTAssertEqual(store.featuredTheme(inCity: "osaka", walkedThemeIds: Set(all.map(\.id)))?.id, all[0].id)
        XCTAssertNil(store.featuredTheme(inCity: "nowhere", walkedThemeIds: []))
    }

    func test_themesFilter_byLens() throws {
        let store = ContentStore(bundle: try loadBundled())
        XCTAssertTrue(store.themes(inCity: "shanghai", lens: .history).allSatisfy { $0.lens == .history })
        XCTAssertFalse(store.themes(inCity: "shanghai", lens: .history).isEmpty)
        XCTAssertTrue(store.themes(inCity: "nowhere", lens: .history).isEmpty)
    }

    func test_bundledContent_everyCityCoversAllSixLenses() throws {
        let content = try loadBundled()
        for city in content.cities {
            let lenses = Set(content.themes.filter { $0.cityId == city.id }.map(\.lens))
            XCTAssertEqual(lenses, Set(Lens.allCases), "\(city.id) 缺少镜头")
        }
    }

    func test_decode_invalidJSON_throws() {
        XCTAssertThrowsError(try ContentStore.decode(Data("{}".utf8)))
    }

    func test_ageBand_boundaries() {
        XCTAssertEqual(AgeBand.forAge(4), .young)
        XCTAssertEqual(AgeBand.forAge(5), .young)
        XCTAssertEqual(AgeBand.forAge(6), .middle)
        XCTAssertEqual(AgeBand.forAge(8), .middle)
        XCTAssertEqual(AgeBand.forAge(9), .older)
        XCTAssertEqual(AgeBand.forAge(12), .older)
    }

    func test_familyProfile_ageAndBand() {
        let profile = FamilyProfile(childNickname: "小满", childBirthYear: 2020, cityId: "shanghai")
        XCTAssertEqual(profile.childAge(currentYear: 2026), 6)
        XCTAssertEqual(profile.ageBand(currentYear: 2026), .middle)
        XCTAssertEqual(profile.childAge(currentYear: 2019), 0)
    }

    func test_strings_allLanguagesHaveDistinctAppCopy() {
        XCTAssertEqual(AppStrings.forLanguage(.zh).tabMap, "地图")
        XCTAssertEqual(AppStrings.forLanguage(.en).tabMap, "Map")
        XCTAssertEqual(AppStrings.forLanguage(.ja).tabMap, "地図")
        for language in AppLanguage.allCases {
            let s = AppStrings.forLanguage(language)
            XCTAssertEqual(Set(Lens.allCases.map(s.lensName)).count, Lens.allCases.count)
            XCTAssertTrue(String(format: s.themeMetaFormat, 1.6, 90).contains("1.6"))
            XCTAssertTrue(String(format: s.walkStopsFormat, 1, 3).contains("3"))
        }
    }
}
