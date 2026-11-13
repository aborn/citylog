// Copyright © 2026 CityLog. All rights reserved.

import SwiftUI

enum Metrics {
    static let cardRadius: CGFloat = 16
    static let cardPadding: CGFloat = 14
    static let screenPadding: CGFloat = 16
    static let spacing: CGFloat = 12
    static let routeLineWidth: CGFloat = 5
}

/// 白底圆角卡片。
struct Card<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) { content }
            .padding(Metrics.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.clSurface)
            .clipShape(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
    }
}

/// 镜头标签。
struct LensBadge: View {
    let lens: Lens

    var body: some View {
        Text(AppStrings.current.lensName(lens))
            .font(.caption.weight(.bold))
            .foregroundStyle(Color.clTextPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(lens.badgeColor)
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
    }
}

/// 品牌色实底主按钮。
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color.clOnBrand)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.clBrand.opacity(configuration.isPressed ? 0.8 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

/// 一个大数字加一行说明。
struct StatTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title2.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(Color.clTextPrimary)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.clTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.clSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

/// 主题卡片：镜头、标题、地点、距离和时长。
struct ThemeCard: View {
    let theme: Theme

    var body: some View {
        let s = AppStrings.current
        Card {
            LensBadge(lens: theme.lens)
            Text(theme.title.text())
                .font(.headline)
                .foregroundStyle(Color.clTextPrimary)
                .multilineTextAlignment(.leading)
            Text(theme.area.text() + " · " + String(format: s.themeMetaFormat, theme.distanceKm, theme.minutes))
                .font(.footnote)
                .foregroundStyle(Color.clTextSecondary)
        }
    }
}

enum Formatters {
    /// 米 → 一位小数的公里数。
    static func km(_ meters: Double) -> String { String(format: "%.1f", meters / 1000) }

    static func day(_ date: Date) -> String {
        date.formatted(.dateTime.year().month().day().weekday())
    }
}
