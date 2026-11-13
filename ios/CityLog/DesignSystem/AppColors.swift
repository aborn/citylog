// Copyright © 2026 CityLog. All rights reserved.

import SwiftUI
import UIKit

/// 城迹的设计系统颜色。取自纸质地图的图例，全部支持浅色和深色。
extension Color {

    // MARK: - Brand

    /// 地图墨绿（品牌色）
    static let clBrand = Color.dynamic(light: "#0F4C45", dark: "#4FB3A2")
    /// 品牌色实底上的文字
    static let clOnBrand = Color.dynamic(light: "#FBFAF3", dark: "#06211D")
    /// 主干道黄：涂亮的路
    static let clRoad = Color(hex: "#FFC531")
    /// 黄色实底上的文字
    static let clOnRoad = Color(hex: "#3A2A00")
    /// 落点橙：当前位置与强调
    static let clPin = Color(hex: "#FF6B4A")

    // MARK: - Surfaces

    static let clBackground = Color.dynamic(light: "#F4F7F2", dark: "#0B1F1C")
    static let clSurface = Color.dynamic(light: "#FFFFFF", dark: "#14322D")
    static let clDivider = Color.dynamic(light: "#DFE8E1", dark: "#234A43")

    // MARK: - Text

    static let clTextPrimary = Color.dynamic(light: "#16302C", dark: "#E7F0EB")
    static let clTextSecondary = Color.dynamic(light: "#667A74", dark: "#9DB3AC")

    // MARK: - Semantic

    static let clWarningSurface = Color.dynamic(light: "#FFF4CF", dark: "#4A3A08")
    static let clError = Color(hex: "#D8432F")

    // MARK: - Helpers

    static func dynamic(light: String, dark: String) -> Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(Color(hex: dark)) : UIColor(Color(hex: light)) })
    }

    init(hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") { cleaned = String(cleaned.dropFirst()) }
        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}

extension Lens {
    /// 镜头标签的底色。
    var badgeColor: Color {
        switch self {
        case .history: return Color.dynamic(light: "#F6D5CB", dark: "#6A2C1C")
        case .culture: return Color.dynamic(light: "#E8D8F2", dark: "#4A2F5E")
        case .industry: return Color.dynamic(light: "#FFE08A", dark: "#6B5200")
        case .planning: return Color.dynamic(light: "#CFE0F5", dark: "#1F3F66")
        case .civic: return Color.dynamic(light: "#D9DEE8", dark: "#39424F")
        case .nature: return Color.dynamic(light: "#CDE5C2", dark: "#2C5226")
        }
    }
}
