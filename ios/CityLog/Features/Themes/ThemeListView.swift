// Copyright © 2026 CityLog. All rights reserved.

import SwiftUI

/// 主题页：这个周末走哪条路。可以按镜头筛选。
struct ThemeListView: View {
    @EnvironmentObject private var contentStore: ContentStore
    @EnvironmentObject private var profileStore: ProfileStore

    @State private var lens: Lens?

    var body: some View {
        let s = AppStrings.current
        let profile = profileStore.profile
        let themes = contentStore.themes(inCity: profile.cityId, lens: lens)
        ScrollView {
            VStack(alignment: .leading, spacing: Metrics.spacing) {
                Text(String(format: s.themesSubtitleFormat, profile.childAge(currentYear: profileStore.currentYear)))
                    .font(.footnote)
                    .foregroundStyle(Color.clTextSecondary)
                lensFilter(s)
                if themes.isEmpty {
                    Text(s.themesEmpty)
                        .font(.subheadline)
                        .foregroundStyle(Color.clTextSecondary)
                        .padding(.top, 24)
                        .frame(maxWidth: .infinity)
                }
                ForEach(themes) { theme in
                    NavigationLink { PrepCardView(theme: theme) } label: { ThemeCard(theme: theme) }
                        .buttonStyle(.plain)
                }
            }
            .padding(Metrics.screenPadding)
        }
        .background(Color.clBackground)
        .navigationTitle(s.themesTitle)
    }

    private func lensFilter(_ s: AppStrings) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                chip(s.lensAll, selected: lens == nil) { lens = nil }
                ForEach(Lens.allCases, id: \.self) { item in
                    chip(s.lensName(item), selected: lens == item) { lens = item }
                }
            }
        }
    }

    private func chip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.footnote.weight(selected ? .bold : .regular))
                .foregroundStyle(selected ? Color.clOnBrand : Color.clTextSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(selected ? Color.clBrand : Color.clSurface)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
