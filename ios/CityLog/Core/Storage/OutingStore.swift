// Copyright © 2026 CityLog. All rights reserved.

import Foundation

/// 出门记录的本地存储。每次出门一个 JSON 文件，照片放在同名目录里。
/// 轨迹、照片默认只存在本机。
@MainActor
final class OutingStore: ObservableObject {
    static let directoryName = "outings"

    @Published private(set) var outings: [Outing] = []

    let directory: URL
    private let fileManager: FileManager

    init(directory: URL? = nil, fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.directory = directory ?? fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(OutingStore.directoryName, isDirectory: true)
        reload()
    }

    /// 重新读取全部记录，最近的排在前面。损坏的文件跳过。
    func reload() {
        let urls = (try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        outings = urls
            .filter { $0.pathExtension == "json" }
            .compactMap { try? OutingStore.decoder.decode(Outing.self, from: Data(contentsOf: $0)) }
            .sorted { $0.startedAt > $1.startedAt }
    }

    func save(_ outing: Outing) throws {
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        try OutingStore.encoder.encode(outing).write(to: fileURL(for: outing.id), options: .atomic)
        reload()
    }

    func delete(_ outing: Outing) throws {
        try? fileManager.removeItem(at: photoDirectory(for: outing.id))
        try fileManager.removeItem(at: fileURL(for: outing.id))
        reload()
    }

    /// 保存一张照片，返回文件名。
    func savePhoto(_ data: Data, outingId: UUID) throws -> String {
        let dir = photoDirectory(for: outingId)
        try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        let name = UUID().uuidString + ".jpg"
        try data.write(to: dir.appendingPathComponent(name), options: .atomic)
        return name
    }

    func photoURL(_ fileName: String, outingId: UUID) -> URL {
        photoDirectory(for: outingId).appendingPathComponent(fileName)
    }

    func outings(inCity cityId: String) -> [Outing] { outings.filter { $0.cityId == cityId } }

    private func fileURL(for id: UUID) -> URL { directory.appendingPathComponent(id.uuidString + ".json") }
    private func photoDirectory(for id: UUID) -> URL {
        directory.appendingPathComponent(id.uuidString, isDirectory: true)
    }

    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
}
