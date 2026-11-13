// Copyright © 2026 CityLog. All rights reserved.

import SwiftUI

/// 备课卡：出门前 5 分钟读完。一句话讲透、路线、问孩子的问题。
struct PrepCardView: View {
    let theme: Theme

    @EnvironmentObject private var contentStore: ContentStore
    @EnvironmentObject private var profileStore: ProfileStore
    @EnvironmentObject private var router: AppRouter

    @State private var band: AgeBand = .middle

    var body: some View {
        let s = AppStrings.current
        ScrollView {
            VStack(alignment: .leading, spacing: Metrics.spacing) {
                LensBadge(lens: theme.lens)
                Text(theme.title.text())
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.clTextPrimary)
                Text(theme.area.text() + " · " + String(format: s.themeMetaFormat, theme.distanceKm, theme.minutes))
                    .font(.footnote)
                    .foregroundStyle(Color.clTextSecondary)

                Picker(s.prepTitle, selection: $band) {
                    ForEach(AgeBand.allCases, id: \.self) { Text(s.ageBandName($0)).tag($0) }
                }
                .pickerStyle(.segmented)

                Card {
                    sectionLabel(s.prepOneLiner)
                    Text(theme.oneLiner(for: band)?.text() ?? "")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.clTextPrimary)
                }

                Card {
                    sectionLabel(s.prepRoute)
                    ForEach(Array(theme.stops.enumerated()), id: \.element.id) { index, stop in
                        stopRow(number: index + 1, stop: stop)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(s.prepAsk).font(.subheadline.weight(.bold))
                    Text(theme.question(for: band)?.text() ?? "").font(.subheadline)
                }
                .foregroundStyle(Color.clTextPrimary)
                .padding(Metrics.cardPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.clWarningSurface)
                .clipShape(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))

                if !theme.verified {
                    Label(s.prepUnverified, systemImage: "exclamationmark.circle")
                        .font(.caption)
                        .foregroundStyle(Color.clTextSecondary)
                }

                Button(s.prepStart) { start() }
                    .buttonStyle(PrimaryButtonStyle())
            }
            .padding(Metrics.screenPadding)
        }
        .background(Color.clBackground)
        .navigationTitle(s.prepTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { band = profileStore.ageBand }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text).font(.caption).foregroundStyle(Color.clTextSecondary)
    }

    private func stopRow(number: Int, stop: Stop) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number)")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.clOnBrand)
                .frame(width: 22, height: 22)
                .background(Color.clBrand)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(stop.name.text()).font(.subheadline.weight(.bold)).foregroundStyle(Color.clTextPrimary)
                Text(stop.story.text()).font(.footnote).foregroundStyle(Color.clTextSecondary)
            }
        }
    }

    private func start() {
        guard let city = contentStore.city(id: theme.cityId) else { return }
        router.walk = WalkRequest(city: city, theme: theme)
    }
}
