import Foundation
import SwiftUI

/// 支持的语言
enum AppLanguage: String, CaseIterable, Identifiable {
    case zhHans = "zh-Hans"
    case zhHant = "zh-Hant"
    case en = "en"
    case ja = "ja"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .zhHans: return "简体中文"
        case .zhHant: return "繁體中文"
        case .en: return "English"
        case .ja: return "日本語"
        }
    }
}

/// 语言管理器
@MainActor
final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "appLanguage")
        }
    }

    private init() {
        if let saved = UserDefaults.standard.string(forKey: "appLanguage"),
           let language = AppLanguage(rawValue: saved) {
            currentLanguage = language
        } else {
            // 默认跟随系统
            let preferredLanguage = Locale.preferredLanguages.first ?? "en"
            if preferredLanguage.hasPrefix("zh-Hans") {
                currentLanguage = .zhHans
            } else if preferredLanguage.hasPrefix("zh-Hant") || preferredLanguage.hasPrefix("zh-TW") || preferredLanguage.hasPrefix("zh-HK") {
                currentLanguage = .zhHant
            } else if preferredLanguage.hasPrefix("ja") {
                currentLanguage = .ja
            } else {
                currentLanguage = .en
            }
        }
    }

    /// 获取本地化字符串
    func localized(_ key: LocalizedKey) -> String {
        return key.string(for: currentLanguage)
    }
}

/// 本地化字符串键
enum LocalizedKey {
    // 通用
    case appName
    case settings
    case cancel
    case confirm
    case save

    // 菜单栏
    case startRecording
    case stopRecording
    case transcribing
    case loadingModel
    case copiedToClipboard
    case quit

    // 设置页
    case generalSettings
    case configureBasicSettings
    case launchAtLogin
    case launchAtLoginDesc
    case interfaceLanguage
    case interfaceLanguageDesc
    case showNotifications
    case showNotificationsDesc
    case shortcuts
    case holdOption
    case holdOptionDesc
    case doubleShift
    case doubleShiftDesc

    // 历史记录
    case history
    case historyDesc
    case noHistory
    case clearHistory
    case copyText
    case deleteRecord

    // 主题
    case appearance
    case appearanceDesc
    case lightMode
    case darkMode
    case systemMode

    // 悬浮窗
    case listening
    case releaseToFinish

    func string(for language: AppLanguage) -> String {
        switch language {
        case .zhHans: return zhHansString
        case .zhHant: return zhHantString
        case .en: return enString
        case .ja: return jaString
        }
    }

    private var zhHansString: String {
        switch self {
        case .appName: return "VoxType"
        case .settings: return "设置"
        case .cancel: return "取消"
        case .confirm: return "确认"
        case .save: return "保存"
        case .startRecording: return "开始录音"
        case .stopRecording: return "停止录音"
        case .transcribing: return "转写中..."
        case .loadingModel: return "正在加载模型..."
        case .copiedToClipboard: return "已复制到剪贴板"
        case .quit: return "退出 VoxType"
        case .generalSettings: return "基本设置"
        case .configureBasicSettings: return "配置应用的基本行为和偏好"
        case .launchAtLogin: return "登录时启动"
        case .launchAtLoginDesc: return "开机自动启动 VoxType"
        case .interfaceLanguage: return "界面语言"
        case .interfaceLanguageDesc: return "选择应用界面的显示语言"
        case .showNotifications: return "显示通知"
        case .showNotificationsDesc: return "转写完成时显示系统通知"
        case .shortcuts: return "快捷键"
        case .holdOption: return "长按 Option"
        case .holdOptionDesc: return "按住录音，松开停止"
        case .doubleShift: return "双击 Shift"
        case .doubleShiftDesc: return "双击开始/停止录音"
        case .history: return "历史记录"
        case .historyDesc: return "查看转写历史"
        case .noHistory: return "暂无历史记录"
        case .clearHistory: return "清空历史"
        case .copyText: return "复制"
        case .deleteRecord: return "删除"
        case .appearance: return "外观"
        case .appearanceDesc: return "选择应用的显示主题"
        case .lightMode: return "浅色模式"
        case .darkMode: return "深色模式"
        case .systemMode: return "跟随系统"
        case .listening: return "正在聆听..."
        case .releaseToFinish: return "松开 ⌥ 或双击 ⇧⇧ 完成"
        }
    }

    private var zhHantString: String {
        switch self {
        case .appName: return "VoxType"
        case .settings: return "設定"
        case .cancel: return "取消"
        case .confirm: return "確認"
        case .save: return "儲存"
        case .startRecording: return "開始錄音"
        case .stopRecording: return "停止錄音"
        case .transcribing: return "轉寫中..."
        case .loadingModel: return "正在載入模型..."
        case .copiedToClipboard: return "已複製到剪貼簿"
        case .quit: return "結束 VoxType"
        case .generalSettings: return "基本設定"
        case .configureBasicSettings: return "配置應用的基本行為和偏好"
        case .launchAtLogin: return "登入時啟動"
        case .launchAtLoginDesc: return "開機自動啟動 VoxType"
        case .interfaceLanguage: return "介面語言"
        case .interfaceLanguageDesc: return "選擇應用介面的顯示語言"
        case .showNotifications: return "顯示通知"
        case .showNotificationsDesc: return "轉寫完成時顯示系統通知"
        case .shortcuts: return "快捷鍵"
        case .holdOption: return "長按 Option"
        case .holdOptionDesc: return "按住錄音，鬆開停止"
        case .doubleShift: return "雙擊 Shift"
        case .doubleShiftDesc: return "雙擊開始/停止錄音"
        case .history: return "歷史記錄"
        case .historyDesc: return "查看轉寫歷史"
        case .noHistory: return "暫無歷史記錄"
        case .clearHistory: return "清空歷史"
        case .copyText: return "複製"
        case .deleteRecord: return "刪除"
        case .appearance: return "外觀"
        case .appearanceDesc: return "選擇應用的顯示主題"
        case .lightMode: return "淺色模式"
        case .darkMode: return "深色模式"
        case .systemMode: return "跟隨系統"
        case .listening: return "正在聆聽..."
        case .releaseToFinish: return "鬆開 ⌥ 或雙擊 ⇧⇧ 完成"
        }
    }

    private var enString: String {
        switch self {
        case .appName: return "VoxType"
        case .settings: return "Settings"
        case .cancel: return "Cancel"
        case .confirm: return "Confirm"
        case .save: return "Save"
        case .startRecording: return "Start Recording"
        case .stopRecording: return "Stop Recording"
        case .transcribing: return "Transcribing..."
        case .loadingModel: return "Loading model..."
        case .copiedToClipboard: return "Copied to clipboard"
        case .quit: return "Quit VoxType"
        case .generalSettings: return "General Settings"
        case .configureBasicSettings: return "Configure basic behavior and preferences"
        case .launchAtLogin: return "Launch at Login"
        case .launchAtLoginDesc: return "Start VoxType when you log in"
        case .interfaceLanguage: return "Language"
        case .interfaceLanguageDesc: return "Select the interface language"
        case .showNotifications: return "Show Notifications"
        case .showNotificationsDesc: return "Show notification when transcription is complete"
        case .shortcuts: return "Shortcuts"
        case .holdOption: return "Hold Option"
        case .holdOptionDesc: return "Hold to record, release to stop"
        case .doubleShift: return "Double Shift"
        case .doubleShiftDesc: return "Double tap to toggle recording"
        case .history: return "History"
        case .historyDesc: return "View transcription history"
        case .noHistory: return "No history yet"
        case .clearHistory: return "Clear History"
        case .copyText: return "Copy"
        case .deleteRecord: return "Delete"
        case .appearance: return "Appearance"
        case .appearanceDesc: return "Select the app theme"
        case .lightMode: return "Light"
        case .darkMode: return "Dark"
        case .systemMode: return "System"
        case .listening: return "Listening..."
        case .releaseToFinish: return "Release ⌥ or double tap ⇧⇧ to finish"
        }
    }

    private var jaString: String {
        switch self {
        case .appName: return "VoxType"
        case .settings: return "設定"
        case .cancel: return "キャンセル"
        case .confirm: return "確認"
        case .save: return "保存"
        case .startRecording: return "録音開始"
        case .stopRecording: return "録音停止"
        case .transcribing: return "変換中..."
        case .loadingModel: return "モデルを読み込み中..."
        case .copiedToClipboard: return "クリップボードにコピーしました"
        case .quit: return "VoxType を終了"
        case .generalSettings: return "基本設定"
        case .configureBasicSettings: return "アプリの基本動作を設定"
        case .launchAtLogin: return "ログイン時に起動"
        case .launchAtLoginDesc: return "ログイン時に VoxType を自動起動"
        case .interfaceLanguage: return "言語"
        case .interfaceLanguageDesc: return "インターフェース言語を選択"
        case .showNotifications: return "通知を表示"
        case .showNotificationsDesc: return "変換完了時に通知を表示"
        case .shortcuts: return "ショートカット"
        case .holdOption: return "Option 長押し"
        case .holdOptionDesc: return "押して録音、離して停止"
        case .doubleShift: return "Shift ダブルタップ"
        case .doubleShiftDesc: return "ダブルタップで録音切替"
        case .history: return "履歴"
        case .historyDesc: return "変換履歴を表示"
        case .noHistory: return "履歴がありません"
        case .clearHistory: return "履歴をクリア"
        case .copyText: return "コピー"
        case .deleteRecord: return "削除"
        case .appearance: return "外観"
        case .appearanceDesc: return "アプリのテーマを選択"
        case .lightMode: return "ライト"
        case .darkMode: return "ダーク"
        case .systemMode: return "システム"
        case .listening: return "聞いています..."
        case .releaseToFinish: return "⌥ を離すか ⇧⇧ で完了"
        }
    }
}

/// 便捷扩展
extension View {
    func localized(_ key: LocalizedKey) -> String {
        LanguageManager.shared.localized(key)
    }
}
