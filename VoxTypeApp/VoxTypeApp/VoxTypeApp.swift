import SwiftUI
import AppKit

// MARK: - 主应用入口
@main
struct VoxTypeApp: App {
    @State private var selectedPage: SidebarMenuItem = .general
    @StateObject private var recordingState = RecordingState.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        // 菜单栏图标
        MenuBarExtra {
            MenuBarContentView(recordingState: recordingState)
        } label: {
            Image(systemName: menuBarIcon)
                .symbolRenderingMode(.hierarchical)
        }

        // 设置窗口
        Window("VoxType 设置", id: "settings") {
            ContentView(selectedPage: $selectedPage)
                .preferredColorScheme(themeManager.colorScheme)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }

    private var menuBarIcon: String {
        switch recordingState.status {
        case .recording:
            return "mic.fill"
        case .transcribing:
            return "waveform"
        default:
            return "mic"
        }
    }
}

// MARK: - 菜单栏内容视图
struct MenuBarContentView: View {
    @ObservedObject var recordingState: RecordingState
    @ObservedObject private var languageManager = LanguageManager.shared
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            // 状态显示
            if !recordingState.isModelLoaded {
                Text(languageManager.localized(.loadingModel))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Divider()
            }

            // 录音按钮
            Button(action: { recordingState.toggleRecording() }) {
                HStack {
                    Image(systemName: recordingState.status.isRecording ? "stop.fill" : "mic.fill")
                    Text(recordingButtonTitle)
                }
            }
            .disabled(!recordingState.isModelLoaded || recordingState.status == .transcribing)

            // 显示转写状态
            if recordingState.status == .transcribing {
                Text(languageManager.localized(.transcribing))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // 最近转写的文本
            if !recordingState.transcribedText.isEmpty {
                Divider()
                Text(languageManager.localized(.copiedToClipboard))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            // 设置
            Button(languageManager.localized(.settings) + "...") {
                openWindow(id: "settings")
                NSApp.activate(ignoringOtherApps: true)
            }
            .keyboardShortcut(",", modifiers: .command)

            Divider()

            // 退出
            Button(languageManager.localized(.quit)) {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
        .task {
            setupGlobalShortcuts()
        }
    }

    private var recordingButtonTitle: String {
        switch recordingState.status {
        case .idle, .error:
            return languageManager.localized(.startRecording)
        case .recording:
            return languageManager.localized(.stopRecording)
        case .transcribing:
            return languageManager.localized(.transcribing)
        }
    }

    private func setupGlobalShortcuts() {
        let shortcutManager = GlobalShortcutManager.shared

        // 长按 Option：按住开始录音，松开停止
        shortcutManager.setOptionHandlers(
            onPress: { [weak recordingState] in
                recordingState?.startRecording()
            },
            onRelease: { [weak recordingState] in
                recordingState?.stopRecording()
            }
        )

        // 双击 Shift：切换录音状态
        shortcutManager.setShiftDoubleClickHandler { [weak recordingState] in
            recordingState?.toggleRecording()
        }

        // 开始监听键盘事件
        shortcutManager.startListening()
    }
}

// MARK: - 主视图容器
struct ContentView: View {
    @Binding var selectedPage: SidebarMenuItem
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.colorScheme) private var colorScheme

    private var colors: ThemeColors {
        ThemeColors(theme: themeManager.currentTheme, systemColorScheme: colorScheme)
    }

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(selectedItem: $selectedPage, colors: colors)

            // 根据选中的页面显示不同内容
            Group {
                switch selectedPage {
                case .phonePairing:
                    PhonePairingContentView()
                case .general:
                    GeneralSettingsContentView()
                case .model:
                    ModelSettingsContentView()
                case .files:
                    FilesContentView()
                case .history:
                    HistoryContentView()
                case .translate:
                    TranslateContentView()
                case .shortcuts:
                    ShortcutsContentView()
                case .aiPrompt:
                    AIPromptContentView()
                case .contact:
                    ContactContentView()
                case .upgradePro:
                    UpgradeProContentView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colors.background)
        }
        .frame(width: 1000, height: 680)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 侧边栏菜单项枚举
enum SidebarMenuItem: String, CaseIterable {
    case general = "settings"
    case phonePairing = "phonePairing"
    case model = "model"
    case files = "files"
    case history = "history"
    case translate = "translate"
    case shortcuts = "shortcuts"
    case aiPrompt = "aiPrompt"
    case contact = "contact"
    case upgradePro = "upgradePro"

    var icon: String {
        switch self {
        case .general: return "gearshape"
        case .phonePairing: return "iphone"
        case .model: return "mic"
        case .files: return "folder"
        case .history: return "clock.arrow.circlepath"
        case .translate: return "globe"
        case .shortcuts: return "keyboard"
        case .aiPrompt: return "sparkles"
        case .contact: return "envelope"
        case .upgradePro: return "crown"
        }
    }

    var showInMenu: Bool {
        switch self {
        case .upgradePro, .model, .files, .aiPrompt, .shortcuts:
            return false
        default:
            return true
        }
    }

    func displayName(for language: AppLanguage) -> String {
        switch self {
        case .general:
            return language == .en ? "Settings" :
                   language == .ja ? "設定" :
                   language == .zhHant ? "設定" : "设置"
        case .phonePairing:
            return language == .en ? "Phone Pairing" :
                   language == .ja ? "スマホ連携" :
                   language == .zhHant ? "手機配對" : "手机配对"
        case .model:
            return language == .en ? "Transcription Model" :
                   language == .ja ? "聴写モデル" :
                   language == .zhHant ? "聽寫模型" : "听写模型"
        case .files:
            return language == .en ? "Transcribed Files" :
                   language == .ja ? "変換ファイル" :
                   language == .zhHant ? "轉錄檔案" : "转录文件"
        case .history:
            return language == .en ? "History" :
                   language == .ja ? "履歴" :
                   language == .zhHant ? "歷史記錄" : "历史记录"
        case .translate:
            return language == .en ? "Translate" :
                   language == .ja ? "翻訳" :
                   language == .zhHant ? "翻譯" : "翻译"
        case .shortcuts:
            return language == .en ? "Shortcuts" :
                   language == .ja ? "ショートカット" :
                   language == .zhHant ? "快捷鍵" : "快捷键"
        case .aiPrompt:
            return language == .en ? "AI Prompts" :
                   language == .ja ? "AI プロンプト" :
                   language == .zhHant ? "AI 提示詞" : "AI 提示词"
        case .contact:
            return language == .en ? "Contact Us" :
                   language == .ja ? "お問い合わせ" :
                   language == .zhHant ? "聯繫我們" : "联系我们"
        case .upgradePro:
            return language == .en ? "Upgrade Pro" :
                   language == .ja ? "Pro にアップグレード" :
                   language == .zhHant ? "升級 Pro" : "升级 Pro"
        }
    }
}

// MARK: - 侧边栏视图
struct SidebarView: View {
    @Binding var selectedItem: SidebarMenuItem
    @ObservedObject private var languageManager = LanguageManager.shared
    let colors: ThemeColors

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // App Header
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(colors.sidebarSelectedBackground)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "mic.fill")
                                .font(.system(size: 14))
                                .foregroundColor(colors.sidebarSelectedText)
                        )

                    Text("VoxType")
                        .font(.custom("Outfit", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(colors.primaryText)
                        .kerning(-0.5)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                // Menu Items
                VStack(spacing: 2) {
                    ForEach(SidebarMenuItem.allCases.filter { $0.showInMenu }, id: \.self) { item in
                        Button(action: { selectedItem = item }) {
                            SidebarMenuItemView(
                                item: item,
                                isSelected: item == selectedItem,
                                colors: colors,
                                language: languageManager.currentLanguage
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
            }
            .padding(.top, 16)

            Spacer()

            // 升级 Pro 按钮
            Button(action: { selectedItem = .upgradePro }) {
                HStack(spacing: 10) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 14))
                        .foregroundColor(colors.sidebarSelectedText)

                    Text(SidebarMenuItem.upgradePro.displayName(for: languageManager.currentLanguage))
                        .font(.custom("Outfit", size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(colors.sidebarSelectedText)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(colors.sidebarSelectedBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.bottom, 16)
        }
        .frame(width: 240)
        .background(colors.sidebarBackground)
    }
}

// MARK: - 侧边栏菜单项视图
struct SidebarMenuItemView: View {
    let item: SidebarMenuItem
    let isSelected: Bool
    let colors: ThemeColors
    let language: AppLanguage

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: item.icon)
                .font(.system(size: 16))
                .foregroundColor(isSelected ? colors.sidebarSelectedText : colors.secondaryText)
                .frame(width: 18, height: 18)

            Text(item.displayName(for: language))
                .font(.custom("Outfit", size: 14))
                .fontWeight(.medium)
                .foregroundColor(isSelected ? colors.sidebarSelectedText : colors.primaryText)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(isSelected ? colors.sidebarSelectedBackground : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
