// Copyright © 2026 CityLog. All rights reserved.

import SwiftUI
import MapKit

/// 一页日志：路线、数据、孩子的话、路上的问答。
struct JournalDetailView: View {
    let outingId: UUID

    @EnvironmentObject private var outingStore: OutingStore
    @EnvironmentObject private var contentStore: ContentStore
    @Environment(\.dismiss) private var dismiss

    @State private var quoteDraft = ""
    @State private var confirmDelete = false

    private static let mapHeight: CGFloat = 220

    var body: some View {
        let s = AppStrings.current
        Group {
            if let outing = outingStore.outings.first(where: { $0.id == outingId }) {
                content(outing, s: s)
            } else {
                Color.clBackground
            }
        }
        .background(Color.clBackground)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func content(_ outing: Outing, s: AppStrings) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Metrics.spacing) {
                Text(Formatters.day(outing.startedAt)).font(.footnote).foregroundStyle(Color.clTextSecondary)
                Text(outing.title).font(.title2.weight(.bold)).foregroundStyle(Color.clTextPrimary)
                if let city = contentStore.city(id: outing.cityId), outing.track.count > 1 {
                    routeMap(outing, city: city)
                }
                HStack(spacing: 8) {
                    StatTile(value: Formatters.km(outing.distanceMeters), label: s.unitKm)
                    StatTile(value: "\(outing.visitedStopIds.count)", label: s.journalStops)
                    StatTile(value: "\(outing.snaps.count)", label: s.journalSnaps)
                }
                quoteCard(outing, s: s)
                ForEach(outing.snaps) { snapCard($0, outing: outing) }
            }
            .padding(Metrics.screenPadding)
        }
        .onAppear { quoteDraft = outing.childQuote }
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) { confirmDelete = true } label: { Image(systemName: "trash") }
            }
        }
        .confirmationDialog(s.journalDeleteConfirm, isPresented: $confirmDelete, titleVisibility: .visible) {
            Button(s.delete, role: .destructive) {
                try? outingStore.delete(outing)
                dismiss()
            }
            Button(s.cancel, role: .cancel) {}
        }
    }

    private func routeMap(_ outing: Outing, city: City) -> some View {
        Map(initialPosition: .automatic, interactionModes: []) {
            MapPolyline(coordinates: outing.track.map { city.displayCoordinate($0.coordinate) })
                .stroke(Color.clRoad, style: StrokeStyle(lineWidth: Metrics.routeLineWidth, lineCap: .round, lineJoin: .round))
        }
        .frame(height: JournalDetailView.mapHeight)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
    }

    private func quoteCard(_ outing: Outing, s: AppStrings) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(s.journalChildSaid).font(.caption)
            TextField(s.journalQuotePlaceholder, text: $quoteDraft, axis: .vertical)
                .font(.body.weight(.semibold))
                .onSubmit { saveQuote(outing) }
        }
        .foregroundStyle(Color.clOnBrand)
        .tint(Color.clOnBrand)
        .padding(Metrics.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.clBrand)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
        .onDisappear { saveQuote(outing) }
    }

    private func snapCard(_ snap: SnapNote, outing: Outing) -> some View {
        Card {
            if let file = snap.photoFile,
               let image = UIImage(contentsOfFile: outingStore.photoURL(file, outingId: outing.id).path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            Text(snap.question).font(.subheadline.weight(.bold)).foregroundStyle(Color.clTextPrimary)
            Text(snap.answer).font(.subheadline).foregroundStyle(Color.clTextPrimary)
        }
    }

    private func saveQuote(_ outing: Outing) {
        let trimmed = quoteDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed != outing.childQuote else { return }
        var updated = outing
        updated.childQuote = trimmed
        try? outingStore.save(updated)
    }
}
