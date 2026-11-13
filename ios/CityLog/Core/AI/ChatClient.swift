// Copyright © 2026 CityLog. All rights reserved.

import Foundation

/// AI 服务设置。使用 OpenAI 兼容的 chat/completions 接口，
/// 这样中国大陆和海外可以各自接入当地可用的模型服务。
struct AIConfig: Equatable {
    var baseURL: String
    var model: String
    var apiKey: String

    var isComplete: Bool {
        ![baseURL, model, apiKey].contains { $0.trimmingCharacters(in: .whitespaces).isEmpty }
    }
}

/// 「拍一拍」提问时带上的现场信息。
struct SnapContext: Equatable {
    let cityName: String
    let themeTitle: String?
    let stopName: String?
    let childAge: Int
    let language: AppLanguage
}

/// 回答「拍一拍」问题的服务。
protocol SnapAnswering {
    func answer(question: String, imageJPEG: Data?, context: SnapContext) async throws -> String
}

/// 请求的构造和返回的解析都是纯函数，方便单测。
enum ChatRequestBuilder {
    static let endpointPath = "chat/completions"
    static let maxAnswerTokens = 400

    static func systemPrompt(_ context: SnapContext) -> String {
        var lines = [
            "You are a city guide helping a parent explain what they see to a child aged \(context.childAge).",
            "City: \(context.cityName)."
        ]
        if let theme = context.themeTitle { lines.append("Today's theme: \(theme).") }
        if let stop = context.stopName { lines.append("They are near: \(stop).") }
        lines.append("Answer in two or three short sentences a child of that age can follow.")
        lines.append("If you are not sure about a fact, say so plainly. Never invent history.")
        lines.append("Then suggest one follow-up question the parent can ask the child.")
        lines.append("Reply in the language with code \(context.language.speechCode).")
        return lines.joined(separator: "\n")
    }

    static func request(config: AIConfig, question: String, imageJPEG: Data?, context: SnapContext) throws -> URLRequest {
        guard config.isComplete else { throw AppError.aiNotConfigured }
        let base = config.baseURL.trimmingCharacters(in: .whitespaces)
        guard let baseURL = URL(string: base), let scheme = baseURL.scheme, scheme.hasPrefix("http") else {
            throw AppError.aiInvalidEndpoint
        }
        var userContent: [[String: Any]] = [["type": "text", "text": question]]
        if let imageJPEG {
            let dataURL = "data:image/jpeg;base64," + imageJPEG.base64EncodedString()
            userContent.append(["type": "image_url", "image_url": ["url": dataURL]])
        }
        let body: [String: Any] = [
            "model": config.model,
            "max_tokens": maxAnswerTokens,
            "messages": [
                ["role": "system", "content": systemPrompt(context)],
                ["role": "user", "content": userContent]
            ]
        ]
        var request = URLRequest(url: baseURL.appendingPathComponent(endpointPath))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }

    static func parseAnswer(_ data: Data) throws -> String {
        struct Response: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable { let content: String? }
                let message: Message
            }
            let choices: [Choice]
        }
        let response = try JSONDecoder().decode(Response.self, from: data)
        let text = response.choices.first?.message.content?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { throw AppError.aiEmptyAnswer }
        return text
    }
}

/// 通过网络调用 AI 服务。
struct RemoteSnapAnswerer: SnapAnswering {
    let config: AIConfig
    var session: URLSession = .shared

    func answer(question: String, imageJPEG: Data?, context: SnapContext) async throws -> String {
        let request = try ChatRequestBuilder.request(config: config, question: question, imageJPEG: imageJPEG, context: context)
        let (data, response) = try await session.data(for: request)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw AppError.aiHTTP(status: http.statusCode)
        }
        return try ChatRequestBuilder.parseAnswer(data)
    }
}
