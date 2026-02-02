import SwiftUI

// MARK: - 设置内容视图
struct GeneralSettingsContentView: View {
    @State private var launchAtLogin = true
    @State private var selectedLanguage = "简体中文"
    @State private var showNotifications = false

    let languages = [
        "简体中文", "繁體中文", "English", "日本語",
        "한국어", "Français", "Deutsch", "Español",
        "Italiano", "Português", "Русский", "العربية"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 页面标题
                VStack(alignment: .leading, spacing: 8) {
                    Text("设置")
                        .font(.custom("Outfit", size: 28))
                        .fontWeight(.bold)
                        .kerning(-1)
                        .foregroundColor(.black)

                    Text("配置应用的基本行为和偏好")
                        .font(.custom("Inter", size: 14))
                        .foregroundColor(Color(hex: "71717A"))
                }

                // 基本设置
                VStack(alignment: .leading, spacing: 16) {
                    Text("基本设置")
                        .font(.custom("Outfit", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    // 登录时启动
                    SettingToggleRow(
                        title: "登录时启动",
                        description: "开机自动启动 VoxType",
                        isOn: $launchAtLogin
                    )

                    // 界面语言
                    SettingDropdownRow(
                        title: "界面语言",
                        description: "选择应用界面的显示语言",
                        options: languages,
                        selected: $selectedLanguage
                    )

                    // 显示通知
                    SettingToggleRow(
                        title: "显示通知",
                        description: "转写完成时显示系统通知",
                        isOn: $showNotifications
                    )
                }

                // 快捷键设置
                VStack(alignment: .leading, spacing: 16) {
                    Text("快捷键设置")
                        .font(.custom("Outfit", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    // 开始/停止录音
                    ShortcutSettingDisplayRow(
                        title: "开始/停止录音",
                        description: "按下快捷键开始或停止语音转写",
                        shortcutName: .toggleRecording
                    )

                    // 暂停/继续录音
                    ShortcutSettingDisplayRow(
                        title: "暂停/继续录音",
                        description: "按下快捷键暂停或继续当前录音",
                        shortcutName: .pauseRecording
                    )
                }
            }
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

// MARK: - 设置下拉行
struct SettingDropdownRow: View {
    let title: String
    let description: String
    let options: [String]
    @Binding var selected: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Outfit", size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)

                Text(description)
                    .font(.custom("Inter", size: 13))
                    .foregroundColor(Color(hex: "71717A"))
            }

            Spacer()

            // 下拉选择器
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selected = option
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(selected)
                        .font(.custom("Inter", size: 13))
                        .fontWeight(.medium)
                        .foregroundColor(.black)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "71717A"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(hex: "E4E4E7"), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(hex: "F4F4F5"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 快捷键设置显示行
struct ShortcutSettingDisplayRow: View {
    let title: String
    let description: String
    let shortcutName: ShortcutName

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Outfit", size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)

                Text(description)
                    .font(.custom("Inter", size: 13))
                    .foregroundColor(Color(hex: "71717A"))
            }

            Spacer()

            // 快捷键显示
            Text(GlobalShortcutManager.shared.getShortcut(shortcutName).displayString)
                .font(.custom("Inter", size: 13))
                .fontWeight(.medium)
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(hex: "E4E4E7"), lineWidth: 1)
                )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(hex: "F4F4F5"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 快捷键设置行 (静态显示，保留兼容)
struct ShortcutSettingRow: View {
    let title: String
    let description: String
    let shortcut: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Outfit", size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)

                Text(description)
                    .font(.custom("Inter", size: 13))
                    .foregroundColor(Color(hex: "71717A"))
            }

            Spacer()

            // 快捷键显示
            Button(action: {}) {
                Text(shortcut)
                    .font(.custom("Inter", size: 13))
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(hex: "E4E4E7"), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(hex: "F4F4F5"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
