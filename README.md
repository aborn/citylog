# 城迹 CityLog

世面，就在家门口。

帮家长带孩子把自己住的城市走遍、走深、走透的 App。首发城市：中国上海、日本大阪。

## 目录

- `ios/` —— Swift iOS 项目（SwiftUI，iOS 17+）
- `docs/` —— 调研结论、产品设计
- `design/` —— UI 稿、logo

## iOS

```bash
cd ios
# 编译（$S 是临时目录）
xcodebuild -scheme CityLog -project CityLog.xcodeproj -destination 'generic/platform=iOS Simulator' -derivedDataPath "$S/dd-ios" build
# 单元测试
xcodebuild test -scheme CityLog -project CityLog.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath "$S/dd-ios"
```

代码结构（参考 PenCursor）：

```
ios/CityLog/
├── App/            入口、TabView、跨页面导航
├── Core/
│   ├── Models/     City、Theme、Outing、FamilyProfile
│   ├── Storage/    内容、出门记录、家庭档案、钥匙串
│   ├── Location/   定位封装
│   ├── AI/         OpenAI 兼容接口的请求构造与解析
│   └── Utils/      坐标转换、轨迹计算、统计、语音
├── DesignSystem/   颜色、三语文案、通用组件
├── Features/       Map、Themes、Walk、Snap、Journal、Family
└── Resources/      content.json（城市与主题内容）
ios/CityLogTests/   XCTest 单元测试
```

“拍一拍”需要在 App 的“我家 → AI 服务”里填写一个 OpenAI 兼容接口（地址、模型、密钥）。密钥只存在本机钥匙串。
