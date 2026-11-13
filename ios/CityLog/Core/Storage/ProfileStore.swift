// Copyright © 2026 CityLog. All rights reserved.

import Foundation

/// 家庭档案与 AI 服务设置。档案和服务地址存 UserDefaults，密钥存钥匙串。
@MainActor
final class ProfileStore: ObservableObject {
    private static let profileKey = "citylog.profile"
    private static let aiBaseURLKey = "citylog.ai.baseURL"
    private static let aiModelKey = "citylog.ai.model"
    private static let aiKeyAccount = "citylog.ai.apiKey"

    @Published var profile: FamilyProfile { didSet { persistProfile() } }
    @Published private(set) var aiConfig: AIConfig

    private let defaults: UserDefaults
    private let secrets: SecretStore

    init(defaults: UserDefaults = .standard, secrets: SecretStore = KeychainStore(), now: Date = Date()) {
        self.defaults = defaults
        self.secrets = secrets
        let year = Calendar.current.component(.year, from: now)
        if let data = defaults.data(forKey: ProfileStore.profileKey),
           let saved = try? JSONDecoder().decode(FamilyProfile.self, from: data) {
            profile = saved
        } else {
            profile = .makeDefault(currentYear: year)
        }
        aiConfig = AIConfig(
            baseURL: defaults.string(forKey: ProfileStore.aiBaseURLKey) ?? "",
            model: defaults.string(forKey: ProfileStore.aiModelKey) ?? "",
            apiKey: secrets.read(account: ProfileStore.aiKeyAccount) ?? ""
        )
    }

    var currentYear: Int { Calendar.current.component(.year, from: Date()) }
    var ageBand: AgeBand { profile.ageBand(currentYear: currentYear) }

    func updateAIConfig(_ config: AIConfig) {
        aiConfig = config
        defaults.set(config.baseURL, forKey: ProfileStore.aiBaseURLKey)
        defaults.set(config.model, forKey: ProfileStore.aiModelKey)
        secrets.write(config.apiKey, account: ProfileStore.aiKeyAccount)
    }

    private func persistProfile() {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        defaults.set(data, forKey: ProfileStore.profileKey)
    }
}
