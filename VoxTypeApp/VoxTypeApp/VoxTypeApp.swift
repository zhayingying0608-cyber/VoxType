import SwiftUI
import AppKit

// MARK: - 主应用入口
@main
struct VoxTypeApp: App {
    @State private var selectedPage: SidebarMenuItem = .general
    @StateObject private var recordingState = RecordingState.shared
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
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            // 状态显示
            if !recordingState.isModelLoaded {
                Text("正在加载模型...")
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
                Text("正在转写...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // 最近转写的文本
            if !recordingState.transcribedText.isEmpty {
                Divider()
                Text("已复制到剪贴板")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            // 设置
            Button("设置...") {
                openWindow(id: "settings")
                NSApp.activate(ignoringOtherApps: true)
            }
            .keyboardShortcut(",", modifiers: .command)

            Divider()

            // 退出
            Button("退出 VoxType") {
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
            return "开始录音"
        case .recording:
            return "停止录音"
        case .transcribing:
            return "转写中..."
        }
    }

    private func setupGlobalShortcuts() {
        let shortcutManager = GlobalShortcutManager.shared

        // 长按开始录音
        shortcutManager.setKeyDownHandler(for: .toggleRecording) { [weak recordingState] in
            recordingState?.startRecording()
        }

        // 释放停止录音
        shortcutManager.setKeyUpHandler(for: .toggleRecording) { [weak recordingState] in
            recordingState?.stopRecording()
        }

        // 开始监听键盘事件
        shortcutManager.startListening()
    }
}

// MARK: - 主视图容器
struct ContentView: View {
    @Binding var selectedPage: SidebarMenuItem

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(selectedItem: $selectedPage)

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
            .background(Color.white)
        }
        .frame(width: 1000, height: 680)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 侧边栏菜单项枚举
enum SidebarMenuItem: String, CaseIterable {
    case general = "设置"
    case phonePairing = "手机配对"
    case model = "听写模型"
    case files = "转录文件"
    case history = "历史记录"
    case translate = "翻译"
    case shortcuts = "快捷键"
    case aiPrompt = "AI 提示词"
    case contact = "联系我们"
    case upgradePro = "升级 Pro"

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
}

// MARK: - 侧边栏视图
struct SidebarView: View {
    @Binding var selectedItem: SidebarMenuItem

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // App Header
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(Color.black)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "mic.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        )

                    Text("VoxType")
                        .font(.custom("Outfit", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .kerning(-0.5)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                // Menu Items
                VStack(spacing: 2) {
                    ForEach(SidebarMenuItem.allCases.filter { $0.showInMenu }, id: \.self) { item in
                        Button(action: { selectedItem = item }) {
                            SidebarMenuItemView(item: item, isSelected: item == selectedItem)
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
                        .foregroundColor(.white)

                    Text("升级 Pro")
                        .font(.custom("Outfit", size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.bottom, 16)
        }
        .frame(width: 240)
        .background(Color(hex: "F4F4F5"))
    }
}

// MARK: - 侧边栏菜单项视图
struct SidebarMenuItemView: View {
    let item: SidebarMenuItem
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: item.icon)
                .font(.system(size: 16))
                .foregroundColor(isSelected ? .white : Color(hex: "71717A"))
                .frame(width: 18, height: 18)

            Text(item.rawValue)
                .font(.custom("Outfit", size: 14))
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .black)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(isSelected ? Color.black : Color.clear)
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
