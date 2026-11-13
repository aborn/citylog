// Copyright © 2026 CityLog. All rights reserved.

import Foundation

enum AppError: Error, Equatable {
    /// App 包里没有内容文件。
    case contentMissing
    /// 还没有配置 AI 服务。
    case aiNotConfigured
    /// AI 服务地址不是合法的 URL。
    case aiInvalidEndpoint
    /// AI 服务返回了错误状态码。
    case aiHTTP(status: Int)
    /// AI 服务的返回内容解析不出回答。
    case aiEmptyAnswer

    func message(_ s: AppStrings = .current) -> String {
        switch self {
        case .contentMissing: return s.errorContentMissing
        case .aiNotConfigured: return s.snapNotConfigured
        case .aiInvalidEndpoint: return s.errorAIEndpoint
        case .aiHTTP(let status): return String(format: s.errorAIHTTPFormat, status)
        case .aiEmptyAnswer: return s.errorAIEmpty
        }
    }
}
