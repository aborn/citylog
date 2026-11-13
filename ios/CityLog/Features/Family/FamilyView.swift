// Copyright © 2026 CityLog. All rights reserved.

import SwiftUI

/// 我家：孩子的档案、所在城市、累计数据、AI 服务设置。
struct FamilyView: View {
    @EnvironmentObject private var contentStore: ContentStore
    @EnvironmentObject private var outingStore: OutingStore
    @EnvironmentObject private var profileStore: ProfileStore

    /// 可选的出生年份范围：覆盖 0–14 岁。
    private static let maxChildAge = 14

    var body: some View {
        let s = AppStrings.current
        Form {
            Section(s.familyChild) {
                TextField(s.familyNickname, text: $profileStore.profile.childNickname)
                Picker(s.familyBirthYear, selection: $profileStore.profile.childBirthYear) {
                    ForEach(birthYears, id: \.self) { Text(String($0)).tag($0) }
                }
            }
            Section(s.familyCity) {
                Picker(s.familyCity, selection: $profileStore.profile.cityId) {
                    ForEach(contentStore.cities) { Text($0.name.text()).tag($0.id) }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            if let city = contentStore.city(id: profileStore.profile.cityId) {
                statsSections(CityStats.make(outings: outingStore.outings, city: city, themes: contentStore.themes), s: s)
            }
            Section {
                NavigationLink {
                    AISettingsView()
                } label: {
                    LabeledContent(s.familyAI, value: profileStore.aiConfig.isComplete ? s.aiConfigured : s.aiNotSet)
                }
            } footer: {
                Text(s.familyPrivacy)
            }
            Section {
                Text(s.slogan)
                    .font(.footnote)
                    .foregroundStyle(Color.clTextSecondary)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.clBackground)
        .navigationTitle(s.tabFamily)
    }

    private var birthYears: [Int] {
        let year = profileStore.currentYear
        return Array((year - FamilyView.maxChildAge...year).reversed())
    }

    @ViewBuilder
    private func statsSections(_ stats: CityStats, s: AppStrings) -> some View {
        Section(s.familyTotals) {
            LabeledContent(s.mapOutings, value: "\(stats.outingCount)")
            LabeledContent(s.mapWalkedKm, value: Formatters.km(stats.distanceMeters))
            LabeledContent(s.mapLitCells, value: "\(stats.litCellCount)")
        }
        Section(s.familyLenses) {
            ForEach(Lens.allCases, id: \.self) { lens in
                LabeledContent {
                    Text("\(stats.lensCounts[lens] ?? 0)").monospacedDigit()
                } label: {
                    LensBadge(lens: lens)
                }
            }
        }
    }
}

/// AI 服务设置：OpenAI 兼容接口的地址、模型和密钥。
struct AISettingsView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @Environment(\.dismiss) private var dismiss

    @State private var baseURL = ""
    @State private var model = ""
    @State private var apiKey = ""

    var body: some View {
        let s = AppStrings.current
        Form {
            Section {
                TextField(s.aiBaseURL, text: $baseURL)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField(s.aiModel, text: $model)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField(s.aiKey, text: $apiKey)
            } footer: {
                Text(s.familyAIHint)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.clBackground)
        .navigationTitle(s.familyAI)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(s.save) {
                    profileStore.updateAIConfig(AIConfig(
                        baseURL: baseURL.trimmingCharacters(in: .whitespaces),
                        model: model.trimmingCharacters(in: .whitespaces),
                        apiKey: apiKey.trimmingCharacters(in: .whitespaces)
                    ))
                    dismiss()
                }
            }
        }
        .onAppear {
            baseURL = profileStore.aiConfig.baseURL
            model = profileStore.aiConfig.model
            apiKey = profileStore.aiConfig.apiKey
        }
    }
}
