# 城迹 CityLog

帮家长带孩子把自己住的城市走遍、走深、走透。首发城市：上海、大阪。产品背景见 `docs/`。

# 项目结构
- `ios/` —— Swift iOS 项目（SwiftUI，iOS 17+，Bundle ID `me.aborn.citylog`）
- `docs/` —— 调研与产品文档
- `design/` —— UI 稿与 logo

# 提交规则
修改 `ios/` 后，先编译并跑通单元测试再提交（`$S` 是当前会话的 scratchpad 目录，任务完成后删除 `dd-ios`）：
```bash
xcodebuild -scheme CityLog -project ios/CityLog.xcodeproj -destination 'generic/platform=iOS Simulator' -derivedDataPath "$S/dd-ios" build
xcodebuild test -scheme CityLog -project ios/CityLog.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath "$S/dd-ios"
```
commit message 用简体中文：`<类型>：<简短描述>`，类型为 新增功能 / 优化功能 / 修复Bug / 重构代码 / 更新配置 / 更新文档。

# iOS 约定
- 分层：`App / Core / DesignSystem / Features`，MVVM。View 只渲染；状态和逻辑放 ViewModel 或 Core 里的纯函数。
- 颜色只从 `DesignSystem/AppColors.swift` 取，必须同时支持浅色和深色。
- 文案只从 `DesignSystem/AppStrings.swift` 取，中、英、日三语都要写。
- 城市和主题内容在 `Resources/content.json`，每段文字三语齐全（有测试检查）。
- 坐标一律存 WGS-84；中国大陆城市显示前用 `City.displayCoordinate` 转 GCJ-02。
- 新增逻辑要有 XCTest 用例，命名 `test_[方法]_[场景]_[预期]`。
- 轨迹、照片、日志只存本机；AI 密钥只存钥匙串。
