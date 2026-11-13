// Copyright © 2026 CityLog. All rights reserved.

import XCTest
@testable import CityLog

private struct StubAnswerer: SnapAnswering {
    let result: Result<String, Error>
    func answer(question: String, imageJPEG: Data?, context: SnapContext) async throws -> String {
        try result.get()
    }
}

@MainActor
final class SnapTests: XCTestCase {

    private let config = AIConfig(baseURL: "https://example.com/v1", model: "vision-model", apiKey: "secret")
    private let context = SnapContext(cityName: "大阪", themeTitle: "天下的厨房", stopName: "淀屋桥", childAge: 6, language: .zh)

    // MARK: - Request building

    func test_request_incompleteConfig_throwsNotConfigured() {
        let empty = AIConfig(baseURL: "", model: "", apiKey: "")
        XCTAssertThrowsError(try ChatRequestBuilder.request(config: empty, question: "q", imageJPEG: nil, context: context)) {
            XCTAssertEqual($0 as? AppError, .aiNotConfigured)
        }
    }

    func test_request_nonHTTPEndpoint_throwsInvalidEndpoint() {
        let bad = AIConfig(baseURL: "example.com/v1", model: "m", apiKey: "k")
        XCTAssertThrowsError(try ChatRequestBuilder.request(config: bad, question: "q", imageJPEG: nil, context: context)) {
            XCTAssertEqual($0 as? AppError, .aiInvalidEndpoint)
        }
    }

    func test_request_buildsChatCompletionWithImage() throws {
        let request = try ChatRequestBuilder.request(config: config, question: "这是什么？", imageJPEG: Data([0xFF, 0xD8]), context: context)
        XCTAssertEqual(request.url?.absoluteString, "https://example.com/v1/chat/completions")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer secret")

        let body = try XCTUnwrap(JSONSerialization.jsonObject(with: XCTUnwrap(request.httpBody)) as? [String: Any])
        XCTAssertEqual(body["model"] as? String, "vision-model")
        let messages = try XCTUnwrap(body["messages"] as? [[String: Any]])
        XCTAssertEqual(messages.map { $0["role"] as? String }, ["system", "user"])
        let parts = try XCTUnwrap(messages[1]["content"] as? [[String: Any]])
        XCTAssertEqual(parts.count, 2)
        XCTAssertEqual(parts[0]["text"] as? String, "这是什么？")
        let imageURL = try XCTUnwrap((parts[1]["image_url"] as? [String: Any])?["url"] as? String)
        XCTAssertTrue(imageURL.hasPrefix("data:image/jpeg;base64,"))
    }

    func test_request_withoutImage_hasTextPartOnly() throws {
        let request = try ChatRequestBuilder.request(config: config, question: "q", imageJPEG: nil, context: context)
        let body = try XCTUnwrap(JSONSerialization.jsonObject(with: XCTUnwrap(request.httpBody)) as? [String: Any])
        let messages = try XCTUnwrap(body["messages"] as? [[String: Any]])
        XCTAssertEqual((messages[1]["content"] as? [[String: Any]])?.count, 1)
    }

    func test_systemPrompt_carriesAgePlaceAndHonestyRule() {
        let prompt = ChatRequestBuilder.systemPrompt(context)
        XCTAssertTrue(prompt.contains("aged 6"))
        XCTAssertTrue(prompt.contains("大阪"))
        XCTAssertTrue(prompt.contains("淀屋桥"))
        XCTAssertTrue(prompt.contains("Never invent history"))
        XCTAssertTrue(prompt.contains("zh-CN"))
    }

    // MARK: - Response parsing

    func test_parseAnswer_returnsTrimmedContent() throws {
        let json = #"{"choices":[{"message":{"role":"assistant","content":"  这是一座桥。 \n"}}]}"#
        XCTAssertEqual(try ChatRequestBuilder.parseAnswer(Data(json.utf8)), "这是一座桥。")
    }

    func test_parseAnswer_emptyOrMissing_throwsEmptyAnswer() {
        for json in [#"{"choices":[]}"#, #"{"choices":[{"message":{"content":"  "}}]}"#, #"{"choices":[{"message":{}}]}"#] {
            XCTAssertThrowsError(try ChatRequestBuilder.parseAnswer(Data(json.utf8)), json) {
                XCTAssertEqual($0 as? AppError, .aiEmptyAnswer)
            }
        }
    }

    // MARK: - SnapViewModel

    private func makeViewModel(config: AIConfig? = nil, result: Result<String, Error>,
                               onSave: @escaping SnapViewModel.SaveHandler = { _, _, _ in }) -> SnapViewModel {
        SnapViewModel(config: config ?? self.config, context: context, answerer: StubAnswerer(result: result),
                      strings: .zh, onSave: onSave)
    }

    func test_canAsk_needsPhotoOrQuestion() {
        let vm = makeViewModel(result: .success("a"))
        XCTAssertFalse(vm.canAsk)
        vm.question = "  "
        XCTAssertFalse(vm.canAsk)
        vm.photoJPEG = Data([1])
        XCTAssertTrue(vm.canAsk)
    }

    func test_ask_withPhotoOnly_usesDefaultQuestion_andSavesOnce() async {
        var saved: [(String, String, Data?)] = []
        let vm = makeViewModel(result: .success("这是锯齿形屋顶。")) { saved.append(($0, $1, $2)) }
        vm.photoJPEG = Data([1])
        await vm.ask()
        XCTAssertEqual(vm.answer, "这是锯齿形屋顶。")
        XCTAssertNil(vm.errorMessage)
        vm.save()
        vm.save()
        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(saved.first?.0, AppStrings.zh.snapDefaultQuestion)
        XCTAssertEqual(saved.first?.2, Data([1]))
        XCTAssertTrue(vm.isSaved)
    }

    func test_ask_notConfigured_showsSetupMessage_withoutCallingService() async {
        let vm = makeViewModel(config: AIConfig(baseURL: "", model: "", apiKey: ""), result: .success("should not appear"))
        vm.question = "这是什么"
        await vm.ask()
        XCTAssertNil(vm.answer)
        XCTAssertEqual(vm.errorMessage, AppStrings.zh.snapNotConfigured)
    }

    func test_ask_serviceError_showsReadableMessage() async {
        let vm = makeViewModel(result: .failure(AppError.aiHTTP(status: 401)))
        vm.question = "这是什么"
        await vm.ask()
        XCTAssertNil(vm.answer)
        XCTAssertEqual(vm.errorMessage, String(format: AppStrings.zh.errorAIHTTPFormat, 401))
        XCTAssertFalse(vm.isLoading)
    }

    func test_save_withoutAnswer_doesNothing() {
        var count = 0
        let vm = makeViewModel(result: .success("a")) { _, _, _ in count += 1 }
        vm.save()
        XCTAssertEqual(count, 0)
    }
}
