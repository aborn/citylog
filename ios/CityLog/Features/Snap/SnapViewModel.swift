// Copyright © 2026 CityLog. All rights reserved.

import Foundation

/// 拍一拍：一张照片加一个问题，AI 用两三句话回答。
@MainActor
final class SnapViewModel: ObservableObject {
    typealias SaveHandler = (_ question: String, _ answer: String, _ photoJPEG: Data?) -> Void

    @Published var question: String = ""
    @Published var photoJPEG: Data?
    @Published private(set) var answer: String?
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false
    @Published private(set) var isSaved = false

    let isConfigured: Bool
    private let answerer: SnapAnswering
    private let context: SnapContext
    private let onSave: SaveHandler
    private let strings: AppStrings

    init(config: AIConfig, context: SnapContext, answerer: SnapAnswering? = nil,
         strings: AppStrings = .current, onSave: @escaping SaveHandler) {
        self.isConfigured = config.isComplete
        self.answerer = answerer ?? RemoteSnapAnswerer(config: config)
        self.context = context
        self.strings = strings
        self.onSave = onSave
    }

    /// 实际发给 AI 的问题：没填就用默认的「这是什么」。
    var effectiveQuestion: String {
        let trimmed = question.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? strings.snapDefaultQuestion : trimmed
    }

    /// 至少要有一张照片或一个问题才能提问。
    var canAsk: Bool {
        !isLoading && (photoJPEG != nil || !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    func ask() async {
        guard canAsk else { return }
        guard isConfigured else {
            errorMessage = AppError.aiNotConfigured.message(strings)
            return
        }
        isLoading = true
        errorMessage = nil
        answer = nil
        isSaved = false
        defer { isLoading = false }
        do {
            answer = try await answerer.answer(question: effectiveQuestion, imageJPEG: photoJPEG, context: context)
        } catch let error as AppError {
            errorMessage = error.message(strings)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save() {
        guard let answer, !isSaved else { return }
        onSave(effectiveQuestion, answer, photoJPEG)
        isSaved = true
    }
}
