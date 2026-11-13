// Copyright © 2026 CityLog. All rights reserved.

import Foundation
import Security

/// 存放密钥的抽象，测试里用内存实现替换。
protocol SecretStore {
    func read(account: String) -> String?
    func write(_ value: String, account: String)
}

/// 用系统钥匙串存 AI 服务密钥。空字符串等同于删除。
struct KeychainStore: SecretStore {
    private static let service = "me.aborn.citylog"

    func read(account: String) -> String? {
        var query = baseQuery(account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func write(_ value: String, account: String) {
        SecItemDelete(baseQuery(account) as CFDictionary)
        guard !value.isEmpty else { return }
        var query = baseQuery(account)
        query[kSecValueData as String] = Data(value.utf8)
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        SecItemAdd(query as CFDictionary, nil)
    }

    private func baseQuery(_ account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainStore.service,
            kSecAttrAccount as String: account
        ]
    }
}

/// 只存在内存里的实现，供测试和预览使用。
final class InMemorySecretStore: SecretStore {
    private var values: [String: String] = [:]
    func read(account: String) -> String? { values[account] }
    func write(_ value: String, account: String) { values[account] = value.isEmpty ? nil : value }
}
