// Copyright © 2026 CityLog. All rights reserved.

import SwiftUI
import MapKit

/// 边走边讲：路上只留两个大按钮，讲解可以用听的。
struct WalkView: View {
    @StateObject var viewModel: WalkViewModel
    let onFinished: () -> Void

    @EnvironmentObject private var outingStore: OutingStore
    @EnvironmentObject private var profileStore: ProfileStore
    @Environment(\.dismiss) private var dismiss

    @StateObject private var tracker = LocationTracker()
    @StateObject private var speaker = Speaker()
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var showSnap = false
    @State private var showQuote = false
    @State private var quoteDraft = ""

    var body: some View {
        let s = AppStrings.current
        NavigationStack {
            VStack(spacing: Metrics.spacing) {
                map
                if tracker.isDenied { notice(s.walkLocationDenied) }
                if let stop = viewModel.currentStop { storyCard(stop, s: s) }
                actions(s)
                Text(s.walkPocketHint).font(.caption).foregroundStyle(Color.clTextSecondary)
                Button(s.walkFinish) { finish(s) }.buttonStyle(PrimaryButtonStyle())
            }
            .padding(Metrics.screenPadding)
            .background(Color.clBackground)
            .navigationTitle(viewModel.theme?.title.text() ?? s.walkFreeTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(s.cancel) { close() } }
            }
        }
        .onAppear { startTracking() }
        .onDisappear { tracker.stop(); speaker.stop() }
        .sheet(isPresented: $showSnap) { snapSheet }
        .alert(s.walkQuotePrompt, isPresented: $showQuote) {
            TextField(s.walkQuote, text: $quoteDraft)
            Button(s.save) { viewModel.childQuote = quoteDraft }
            Button(s.cancel, role: .cancel) {}
        }
    }

    private var map: some View {
        let s = AppStrings.current
        return Map(position: $position) {
            UserAnnotation()
            if viewModel.track.count > 1 {
                MapPolyline(coordinates: viewModel.track.map { viewModel.city.displayCoordinate($0.coordinate) })
                    .stroke(Color.clRoad, style: StrokeStyle(lineWidth: Metrics.routeLineWidth, lineCap: .round, lineJoin: .round))
            }
            ForEach(viewModel.stops) { stop in
                Marker(stop.name.text(), coordinate: viewModel.city.displayCoordinate(stop.coordinate))
                    .tint(viewModel.visitedStopIds.contains(stop.id) ? Color.clBrand : Color.clPin)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
        .overlay(alignment: .topLeading) {
            HStack(spacing: 8) {
                Text(viewModel.track.isEmpty ? s.walkWaitingGPS : Formatters.km(viewModel.distanceMeters) + " " + s.unitKm)
                if !viewModel.stops.isEmpty {
                    Text(String(format: s.walkStopsFormat, viewModel.visitedStopIds.count, viewModel.stops.count))
                }
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.clTextPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.clSurface)
            .clipShape(Capsule())
            .padding(10)
        }
    }

    private func storyCard(_ stop: Stop, s: AppStrings) -> some View {
        Card {
            HStack {
                Text(stop.name.text()).font(.headline).foregroundStyle(Color.clTextPrimary)
                Spacer()
                Button {
                    speaker.toggle(stop.story.text())
                } label: {
                    Label(speaker.isSpeaking ? s.walkStopListening : s.walkListen,
                          systemImage: speaker.isSpeaking ? "stop.fill" : "play.fill")
                        .font(.footnote.weight(.semibold))
                }
            }
            Text(stop.story.text()).font(.subheadline).foregroundStyle(Color.clTextPrimary)
        }
    }

    private func actions(_ s: AppStrings) -> some View {
        HStack(spacing: 8) {
            bigAction(title: s.walkSnap, hint: s.walkSnapHint, icon: "camera.fill", fill: .clRoad, text: .clOnRoad) {
                showSnap = true
            }
            bigAction(title: s.walkQuote, hint: s.walkQuoteHint, icon: "quote.bubble.fill", fill: .clPin, text: .white) {
                quoteDraft = viewModel.childQuote
                showQuote = true
            }
        }
    }

    private func bigAction(title: String, hint: String, icon: String, fill: Color, text: Color,
                           action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Label(title, systemImage: icon).font(.headline)
                Text(hint).font(.caption)
            }
            .foregroundStyle(text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Metrics.cardPadding)
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func notice(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(Color.clTextPrimary)
            .padding(Metrics.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.clWarningSurface)
            .clipShape(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
    }

    private var snapSheet: some View {
        SnapView(viewModel: SnapViewModel(
            config: profileStore.aiConfig,
            context: SnapContext(
                cityName: viewModel.city.name.text(),
                themeTitle: viewModel.theme?.title.text(),
                stopName: viewModel.currentStop?.name.text(),
                childAge: profileStore.profile.childAge(currentYear: profileStore.currentYear),
                language: .current
            ),
            onSave: { question, answer, photo in
                let file = photo.flatMap { try? outingStore.savePhoto($0, outingId: viewModel.outingId) }
                viewModel.addSnap(question: question, answer: answer, photoFile: file)
            }
        ))
    }

    private func startTracking() {
        tracker.onLocation = { location in
            viewModel.ingest(
                coordinate: Coordinate(lat: location.coordinate.latitude, lon: location.coordinate.longitude),
                accuracy: location.horizontalAccuracy,
                at: location.timestamp
            )
        }
        tracker.start()
    }

    private func finish(_ s: AppStrings) {
        guard viewModel.hasContent else { return close() }
        try? outingStore.save(viewModel.makeOuting(freeWalkTitle: s.walkFreeTitle))
        dismiss()
        onFinished()
    }

    private func close() {
        dismiss()
    }
}
