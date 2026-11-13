// Copyright © 2026 CityLog. All rights reserved.

import SwiftUI

/// 日志列表：每次出门一页。
struct JournalListView: View {
    @EnvironmentObject private var outingStore: OutingStore

    var body: some View {
        let s = AppStrings.current
        ScrollView {
            VStack(spacing: Metrics.spacing) {
                if outingStore.outings.isEmpty {
                    Text(s.journalEmpty)
                        .font(.subheadline)
                        .foregroundStyle(Color.clTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 48)
                }
                ForEach(outingStore.outings) { outing in
                    NavigationLink { JournalDetailView(outingId: outing.id) } label: { row(outing, s: s) }
                        .buttonStyle(.plain)
                }
            }
            .padding(Metrics.screenPadding)
        }
        .background(Color.clBackground)
        .navigationTitle(s.tabJournal)
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
