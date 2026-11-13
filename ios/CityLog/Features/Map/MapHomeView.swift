// Copyright © 2026 CityLog. All rights reserved.

import SwiftUI
import MapKit

/// 首页：纸质地图加彩笔的数字版。走过的路涂成黄色，下方给出这个周末去哪。
struct MapHomeView: View {
    @EnvironmentObject private var contentStore: ContentStore
    @EnvironmentObject private var outingStore: OutingStore
    @EnvironmentObject private var profileStore: ProfileStore
    @EnvironmentObject private var router: AppRouter

    @State private var position: MapCameraPosition = .automatic

    private static let citySpanMeters: CLLocationDistance = 9_000

    var body: some View {
        let s = AppStrings.current
        Group {
            if let city = contentStore.city(id: profileStore.profile.cityId) {
                content(city: city, s: s)
            } else {
                ContentUnavailableView(s.errorContentMissing, systemImage: "map")
            }
        }
        .background(Color.clBackground)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func content(city: City, s: AppStrings) -> some View {
        let outings = outingStore.outings(inCity: city.id)
        let stats = CityStats.make(outings: outings, city: city, themes: contentStore.themes)
        let featured = contentStore.featuredTheme(inCity: city.id, walkedThemeIds: stats.walkedThemeIds)
        return VStack(spacing: Metrics.spacing) {
            header(city: city, stats: stats, s: s)
            map(city: city, outings: outings, featured: featured)
            if let featured { featuredCard(featured, s: s) }
            Button(s.mapFreeWalk) { router.walk = WalkRequest(city: city, theme: nil) }
                .font(.subheadline.weight(.semibold))
        }
        .padding(.horizontal, Metrics.screenPadding)
        .padding(.bottom, Metrics.spacing)
        .onAppear { recenter(city) }
        .onChange(of: city.id) { recenter(city) }
    }

    private func header(city: City, stats: CityStats, s: AppStrings) -> some View {
        VStack(alignment: .leading, spacing: Metrics.spacing) {
            Text(String(format: s.mapTitleFormat, city.name.text()))
                .font(.title.weight(.bold))
                .foregroundStyle(Color.clTextPrimary)
            HStack(spacing: 8) {
                StatTile(value: Formatters.km(stats.distanceMeters), label: s.mapWalkedKm)
                StatTile(value: "\(stats.litCellCount)", label: s.mapLitCells)
                StatTile(value: "\(stats.outingCount)", label: s.mapOutings)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func map(city: City, outings: [Outing], featured: Theme?) -> some View {
        Map(position: $position) {
            UserAnnotation()
            ForEach(outings) { outing in
                if outing.track.count > 1 {
                    MapPolyline(coordinates: outing.track.map { city.displayCoordinate($0.coordinate) })
                        .stroke(Color.clRoad, style: StrokeStyle(lineWidth: Metrics.routeLineWidth, lineCap: .round, lineJoin: .round))
                }
            }
            if let featured {
                ForEach(featured.stops) { stop in
                    Marker(stop.name.text(), coordinate: city.displayCoordinate(stop.coordinate))
                        .tint(Color.clPin)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
    }

    private func featuredCard(_ theme: Theme, s: AppStrings) -> some View {
        Card {
            HStack {
                LensBadge(lens: theme.lens)
                Spacer()
                Text(s.mapThisWeekend).font(.caption).foregroundStyle(Color.clTextSecondary)
            }
            Text(theme.title.text()).font(.headline).foregroundStyle(Color.clTextPrimary)
            Text(theme.area.text() + " · " + String(format: s.themeMetaFormat, theme.distanceKm, theme.minutes))
                .font(.footnote)
                .foregroundStyle(Color.clTextSecondary)
            NavigationLink(s.mapOpenPrep) { PrepCardView(theme: theme) }
                .buttonStyle(PrimaryButtonStyle())
        }
    }

    private func recenter(_ city: City) {
        position = .region(MKCoordinateRegion(
            center: city.displayCoordinate(city.center),
            latitudinalMeters: MapHomeView.citySpanMeters,
            longitudinalMeters: MapHomeView.citySpanMeters
        ))
    }
}
