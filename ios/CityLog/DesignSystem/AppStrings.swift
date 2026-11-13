// Copyright © 2026 CityLog. All rights reserved.

import Foundation

/// 全部界面文案，支持中文、英文、日文。
struct AppStrings {
    // MARK: - General
    let appName: String
    let slogan: String
    let ok: String
    let cancel: String
    let save: String
    let delete: String
    let done: String

    // MARK: - Tabs
    let tabMap: String
    let tabThemes: String
    let tabJournal: String
    let tabFamily: String

    // MARK: - Map
    /// 含 %@（城市名）
    let mapTitleFormat: String
    let mapWalkedKm: String
    let mapLitCells: String
    let mapOutings: String
    let mapThisWeekend: String
    let mapOpenPrep: String
    let mapFreeWalk: String

    // MARK: - Lens
    let lensAll: String
    let lensHistory: String
    let lensCulture: String
    let lensIndustry: String
    let lensPlanning: String
    let lensCivic: String
    let lensNature: String

    // MARK: - Themes & prep card
    let themesTitle: String
    /// 含 %d（孩子年龄）
    let themesSubtitleFormat: String
    /// 含 %.1f（公里）与 %d（分钟）
    let themeMetaFormat: String
    let themesEmpty: String
    let prepTitle: String
    let prepOneLiner: String
    let prepRoute: String
    let prepAsk: String
    let prepStart: String
    let prepUnverified: String
    let ageYoung: String
    let ageMiddle: String
    let ageOlder: String

    // MARK: - Walk
    let walkFreeTitle: String
    let walkSnap: String
    let walkSnapHint: String
    let walkQuote: String
    let walkQuoteHint: String
    let walkQuotePrompt: String
    let walkFinish: String
    /// 含两个 %d（到过的站数、总站数）
    let walkStopsFormat: String
    let walkListen: String
    let walkStopListening: String
    let walkLocationDenied: String
    let walkPocketHint: String
    let walkWaitingGPS: String

    // MARK: - Snap
    let snapCamera: String
    let snapLibrary: String
    let snapQuestionPlaceholder: String
    let snapDefaultQuestion: String
    let snapAsk: String
    let snapThinking: String
    let snapSave: String
    let snapNotConfigured: String

    // MARK: - Journal
    let journalEmptyTitle: String
    let journalEmpty: String
    let journalPickTheme: String
    let unitKm: String
    let journalStops: String
    let journalSnaps: String
    let journalChildSaid: String
    let journalQuotePlaceholder: String
    let journalDeleteConfirm: String

    // MARK: - Family
    let familyChild: String
    let familyNickname: String
    let familyBirthYear: String
    let familyCity: String
    let familyTotals: String
    let familyLenses: String
    let familyAI: String
    let familyAIHint: String
    let aiBaseURL: String
    let aiModel: String
    let aiKey: String
    let aiConfigured: String
    let aiNotSet: String
    let familyPrivacy: String

    // MARK: - Errors
    let errorContentMissing: String
    let errorAIEndpoint: String
    /// 含 %d（HTTP 状态码）
    let errorAIHTTPFormat: String
    let errorAIEmpty: String

    static var current: AppStrings { forLanguage(.current) }

    static func forLanguage(_ language: AppLanguage) -> AppStrings {
        switch language {
        case .zh: return zh
        case .en: return en
        case .ja: return ja
        }
    }

    func lensName(_ lens: Lens) -> String {
        switch lens {
        case .history: return lensHistory
        case .culture: return lensCulture
        case .industry: return lensIndustry
        case .planning: return lensPlanning
        case .civic: return lensCivic
        case .nature: return lensNature
        }
    }

    func ageBandName(_ band: AgeBand) -> String {
        switch band {
        case .young: return ageYoung
        case .middle: return ageMiddle
        case .older: return ageOlder
        }
    }
}

extension AppStrings {
    static let zh = AppStrings(
        appName: "城迹", slogan: "世面，就在家门口。", ok: "好", cancel: "取消", save: "保存", delete: "删除", done: "完成",
        tabMap: "地图", tabThemes: "主题", tabJournal: "日志", tabFamily: "我家",
        mapTitleFormat: "我家的%@", mapWalkedKm: "已走公里", mapLitCells: "点亮格子", mapOutings: "出门次数",
        mapThisWeekend: "本周末主题", mapOpenPrep: "看备课卡", mapFreeWalk: "自由走走",
        lensAll: "全部", lensHistory: "历史", lensCulture: "人文", lensIndustry: "产业",
        lensPlanning: "规划", lensCivic: "公共", lensNature: "自然",
        themesTitle: "这个周末走哪条路", themesSubtitleFormat: "按孩子 %d 岁推荐",
        themeMetaFormat: "%.1f 公里 · 约 %d 分钟", themesEmpty: "这座城市的这个镜头还没有主题。",
        prepTitle: "备课卡", prepOneLiner: "一句话讲透", prepRoute: "路线", prepAsk: "问孩子", prepStart: "出发",
        prepUnverified: "这张卡的内容还没有逐条核对史料，讲给孩子前请自己判断。",
        ageYoung: "4–6 岁", ageMiddle: "6–9 岁", ageOlder: "9–12 岁",
        walkFreeTitle: "自由走走", walkSnap: "拍一拍", walkSnapHint: "看到什么问什么",
        walkQuote: "孩子的话", walkQuoteHint: "记下他的版本", walkQuotePrompt: "孩子刚才说了什么？",
        walkFinish: "结束，生成日志", walkStopsFormat: "到过 %d 站，共 %d 站",
        walkListen: "听讲解", walkStopListening: "停止",
        walkLocationDenied: "没有定位权限，无法记录走过的路。请在系统设置里允许城迹使用定位。",
        walkPocketHint: "手机可以收起来，路线会继续记录。", walkWaitingGPS: "正在等待定位…",
        snapCamera: "拍照", snapLibrary: "从相册选",
        snapQuestionPlaceholder: "想问什么？不填就问“这是什么”", snapDefaultQuestion: "这是什么？讲给孩子听。",
        snapAsk: "问 AI", snapThinking: "正在看…", snapSave: "存进今天的日志",
        snapNotConfigured: "还没有配置 AI 服务。请到“我家 → AI 服务”里填写。",
        journalEmptyTitle: "还没有出门记录", journalEmpty: "每次出门回来，这里会多一页：走过的路、孩子说的话、路上问过的问题。", journalPickTheme: "挑一个主题", unitKm: "公里",
        journalStops: "到过的站", journalSnaps: "个问答", journalChildSaid: "孩子说",
        journalQuotePlaceholder: "补记一句孩子说的话", journalDeleteConfirm: "删除这页日志？",
        familyChild: "孩子", familyNickname: "昵称", familyBirthYear: "出生年份", familyCity: "城市",
        familyTotals: "累计", familyLenses: "用过的镜头", familyAI: "AI 服务",
        familyAIHint: "用于“拍一拍”。可填写任意 OpenAI 兼容接口。密钥只保存在本机钥匙串。",
        aiBaseURL: "接口地址", aiModel: "模型", aiKey: "密钥", aiConfigured: "已配置", aiNotSet: "未配置",
        familyPrivacy: "轨迹、照片和日志只保存在这台手机上。",
        errorContentMissing: "内容文件缺失。", errorAIEndpoint: "AI 接口地址不正确，应以 http 或 https 开头。",
        errorAIHTTPFormat: "AI 服务返回了错误（%d）。请检查接口地址、模型和密钥。",
        errorAIEmpty: "AI 没有给出回答，请再试一次。"
    )

    static let en = AppStrings(
        appName: "CityLog", slogan: "See deeper, not farther.", ok: "OK", cancel: "Cancel", save: "Save", delete: "Delete", done: "Done",
        tabMap: "Map", tabThemes: "Themes", tabJournal: "Journal", tabFamily: "Family",
        mapTitleFormat: "Our %@", mapWalkedKm: "km walked", mapLitCells: "cells lit", mapOutings: "outings",
        mapThisWeekend: "This weekend", mapOpenPrep: "Open prep card", mapFreeWalk: "Free walk",
        lensAll: "All", lensHistory: "History", lensCulture: "Culture", lensIndustry: "Industry",
        lensPlanning: "Planning", lensCivic: "Civic", lensNature: "Nature",
        themesTitle: "Where to walk this weekend", themesSubtitleFormat: "Picked for a %d-year-old",
        themeMetaFormat: "%.1f km · about %d min", themesEmpty: "No themes for this lens in this city yet.",
        prepTitle: "Prep card", prepOneLiner: "In one sentence", prepRoute: "Route", prepAsk: "Ask your child", prepStart: "Start",
        prepUnverified: "This card has not been checked against sources line by line. Use your own judgement.",
        ageYoung: "Ages 4–6", ageMiddle: "Ages 6–9", ageOlder: "Ages 9–12",
        walkFreeTitle: "Free walk", walkSnap: "Snap", walkSnapHint: "Ask about what you see",
        walkQuote: "Child's words", walkQuoteHint: "Write down their version", walkQuotePrompt: "What did your child just say?",
        walkFinish: "Finish and save journal", walkStopsFormat: "%d of %d stops visited",
        walkListen: "Listen", walkStopListening: "Stop",
        walkLocationDenied: "Location access is off, so the route cannot be recorded. Allow it in Settings.",
        walkPocketHint: "You can put the phone away. The route keeps recording.", walkWaitingGPS: "Waiting for location…",
        snapCamera: "Camera", snapLibrary: "Photo library",
        snapQuestionPlaceholder: "What do you want to ask? Leave empty for \"What is this?\"", snapDefaultQuestion: "What is this? Explain it to a child.",
        snapAsk: "Ask AI", snapThinking: "Looking…", snapSave: "Save to today's journal",
        snapNotConfigured: "The AI service is not set up yet. Add it under Family → AI service.",
        journalEmptyTitle: "No outings yet", journalEmpty: "Each outing adds a page here: the route you walked, what your child said, and the questions you asked along the way.", journalPickTheme: "Pick a theme", unitKm: "km",
        journalStops: "stops visited", journalSnaps: "Q&As", journalChildSaid: "Your child said",
        journalQuotePlaceholder: "Add something your child said", journalDeleteConfirm: "Delete this journal page?",
        familyChild: "Child", familyNickname: "Nickname", familyBirthYear: "Birth year", familyCity: "City",
        familyTotals: "Totals", familyLenses: "Lenses used", familyAI: "AI service",
        familyAIHint: "Used by Snap. Any OpenAI-compatible endpoint works. The key is stored only in this device's keychain.",
        aiBaseURL: "Endpoint", aiModel: "Model", aiKey: "API key", aiConfigured: "Set up", aiNotSet: "Not set",
        familyPrivacy: "Routes, photos and journals are stored only on this phone.",
        errorContentMissing: "The content file is missing.", errorAIEndpoint: "The AI endpoint is not valid. It should start with http or https.",
        errorAIHTTPFormat: "The AI service returned an error (%d). Check the endpoint, model and key.",
        errorAIEmpty: "The AI gave no answer. Try again."
    )

    static let ja = AppStrings(
        appName: "CityLog", slogan: "世界は、家のすぐそばに。", ok: "OK", cancel: "キャンセル", save: "保存", delete: "削除", done: "完了",
        tabMap: "地図", tabThemes: "テーマ", tabJournal: "日誌", tabFamily: "わが家",
        mapTitleFormat: "わが家の%@", mapWalkedKm: "歩いた km", mapLitCells: "ぬったマス", mapOutings: "おでかけ",
        mapThisWeekend: "今週末のテーマ", mapOpenPrep: "予習カードを見る", mapFreeWalk: "自由に歩く",
        lensAll: "すべて", lensHistory: "歴史", lensCulture: "文化", lensIndustry: "産業",
        lensPlanning: "まちづくり", lensCivic: "公共", lensNature: "自然",
        themesTitle: "今週末はどの道を歩く？", themesSubtitleFormat: "%d 歳向けのおすすめ",
        themeMetaFormat: "%.1f km・約 %d 分", themesEmpty: "この街には、このレンズのテーマがまだありません。",
        prepTitle: "予習カード", prepOneLiner: "ひとことで", prepRoute: "ルート", prepAsk: "子どもに聞く", prepStart: "出発",
        prepUnverified: "このカードの内容は、資料との照合がまだ終わっていません。ご自身で判断してください。",
        ageYoung: "4〜6 歳", ageMiddle: "6〜9 歳", ageOlder: "9〜12 歳",
        walkFreeTitle: "自由に歩く", walkSnap: "撮って聞く", walkSnapHint: "見たものを質問",
        walkQuote: "子どものことば", walkQuoteHint: "その子の言い方で記録", walkQuotePrompt: "いま、お子さんは何と言いましたか？",
        walkFinish: "終了して日誌を作る", walkStopsFormat: "%d / %d か所に到着",
        walkListen: "聞く", walkStopListening: "停止",
        walkLocationDenied: "位置情報が許可されていないため、歩いた道を記録できません。設定で許可してください。",
        walkPocketHint: "スマホをしまっても、ルートは記録されます。", walkWaitingGPS: "位置情報を待っています…",
        snapCamera: "カメラ", snapLibrary: "写真から選ぶ",
        snapQuestionPlaceholder: "何を聞きますか？空欄なら「これは何？」", snapDefaultQuestion: "これは何？子どもに説明して。",
        snapAsk: "AI に聞く", snapThinking: "見ています…", snapSave: "今日の日誌に保存",
        snapNotConfigured: "AI サービスが未設定です。「わが家 → AI サービス」で設定してください。",
        journalEmptyTitle: "まだ記録がありません", journalEmpty: "おでかけのたびに、ここに1ページ増えます。歩いた道、子どものことば、途中で聞いた質問が残ります。", journalPickTheme: "テーマを選ぶ", unitKm: "km",
        journalStops: "到着した場所", journalSnaps: "件の質問", journalChildSaid: "子どものことば",
        journalQuotePlaceholder: "お子さんのことばを書きとめる", journalDeleteConfirm: "この日誌を削除しますか？",
        familyChild: "子ども", familyNickname: "ニックネーム", familyBirthYear: "生まれ年", familyCity: "街",
        familyTotals: "これまで", familyLenses: "使ったレンズ", familyAI: "AI サービス",
        familyAIHint: "「撮って聞く」で使います。OpenAI 互換のエンドポイントを設定できます。キーはこの端末のキーチェーンにだけ保存されます。",
        aiBaseURL: "エンドポイント", aiModel: "モデル", aiKey: "API キー", aiConfigured: "設定済み", aiNotSet: "未設定",
        familyPrivacy: "ルート、写真、日誌はこのスマホにだけ保存されます。",
        errorContentMissing: "コンテンツファイルがありません。", errorAIEndpoint: "AI のエンドポイントが正しくありません。http または https で始めてください。",
        errorAIHTTPFormat: "AI サービスがエラーを返しました（%d）。エンドポイント、モデル、キーを確認してください。",
        errorAIEmpty: "AI から回答がありませんでした。もう一度お試しください。"
    )
}
