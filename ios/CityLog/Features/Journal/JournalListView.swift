// Copyright © 2026 CityLog. All rights reserved.

import SwiftUI

/// 日志列表：每次出门一页。
struct JournalListView: View {
    @EnvironmentObject private var outingStore: OutingStore
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        let s = AppStrings.current
        ScrollView {
            VStack(spacing: Metrics.spacing) {
                if outingStore.outings.isEmpty { emptyState(s) }
                ForEach(outingStore.outings) { outing in
                    NavigationLink { JournalDetailView(outingId: outing.id) } label: { row(outing, s: s) }
                        .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(Metrics.screenPadding)
        }
        .frame(maxWidth: .infinity)
        .background(Color.clBackground.ignoresSafeArea())
        .navigationTitle(s.tabJournal)
    }

    /// 空态：说明这里会出现什么，并给出下一步。
    private func emptyState(_ s: AppStrings) -> some View {
        Card {
            Image(systemName: "book.closed")
                .font(.largeTitle)
                .foregroundStyle(Color.clBrand)
            Text(s.journalEmptyTitle)
                .font(.headline)
                .foregroundStyle(Color.clTextPrimary)
            Text(s.journalEmpty)
                .font(.subheadline)
                .foregroundStyle(Color.clTextSecondary)
            Button(s.journalPickTheme) { router.selectedTab = .themes }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 4)
        }
    }

    private func row(_ outing: Outing, s: AppStrings) -> some View {
        Card {
            Text(Formatters.day(outing.startedAt)).font(.caption).foregroundStyle(Color.clTextSecondary)
            Text(outing.title).font(.headline).foregroundStyle(Color.clTextPrimary).multilineTextAlignment(.leading)
            if !outing.childQuote.isEmpty {
                Text("“\(outing.childQuote)”").font(.subheadline).foregroundStyle(Color.clTextPrimary)
            }
            Text("\(Formatters.km(outing.distanceMeters)) \(s.unitKm) · \(outing.snaps.count) \(s.journalSnaps)")
                .font(.footnote)
                .foregroundStyle(Color.clTextSecondary)
        }
    }
}
