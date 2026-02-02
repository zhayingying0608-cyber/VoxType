import SwiftUI

// MARK: - 设置内容视图
struct GeneralSettingsContentView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.colorScheme) private var colorScheme

    @State private var launchAtLogin = true
    @State private var showNotifications = false

    private var colors: ThemeColors {
        ThemeColors(theme: themeManager.currentTheme, systemColorScheme: colorScheme)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 页面标题
                VStack(alignment: .leading, spacing: 8) {
                    Text(languageManager.localized(.generalSettings))
                        .font(.custom("Outfit", size: 28))
                        .fontWeight(.bold)
                        .kerning(-1)
                        .foregroundColor(colors.primaryText)

                    Text(languageManager.localized(.configureBasicSettings))
                        .font(.custom("Inter", size: 14))
                        .foregroundColor(colors.secondaryText)
                }

                // 基本设置
                VStack(alignment: .leading, spacing: 16) {
                    Text(languageManager.localized(.generalSettings))
                        .font(.custom("Outfit", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(colors.primaryText)

                    // 登录时启动
                    SettingToggleRow(
                        title: languageManager.localized(.launchAtLogin),
                        description: languageManager.localized(.launchAtLoginDesc),
                        isOn: $launchAtLogin,
                        colors: colors
                    )

                    // 界面语言
                    LanguagePickerRow(colors: colors)

                    // 外观主题
                    ThemePickerRow(colors: colors)

                    // 显示通知
                    SettingToggleRow(
                        title: languageManager.localized(.showNotifications),
                        description: languageManager.localized(.showNotificationsDesc),
                        isOn: $showNotifications,
                        colors: colors
                    )
                }

                // 快捷键设置
                VStack(alignment: .leading, spacing: 16) {
                    Text(languageManager.localized(.shortcuts))
                        .font(.custom("Outfit", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(colors.primaryText)

                    // 长按 Option
                    ShortcutSettingRow(
                        title: languageManager.localized(.holdOption),
                        description: languageManager.localized(.holdOptionDesc),
                        shortcut: "⌥ 长按",
                        colors: colors
                    )

                    // 双击 Shift
                    ShortcutSettingRow(
                        title: languageManager.localized(.doubleShift),
                        description: languageManager.localized(.doubleShiftDesc),
                        shortcut: "⇧⇧",
                        colors: colors
                    )
                }
            }
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colors.background)
    }
}

// MARK: - 语言选择行
struct LanguagePickerRow: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    let colors: ThemeColors

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(languageManager.localized(.interfaceLanguage))
                    .font(.custom("Outfit", size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(colors.primaryText)

                Text(languageManager.localized(.interfaceLanguageDesc))
                    .font(.custom("Inter", size: 13))
                    .foregroundColor(colors.secondaryText)
            }

            Spacer()

            Menu {
                ForEach(AppLanguage.allCases) { language in
                    Button(language.displayName) {
                        languageManager.currentLanguage = language
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(languageManager.currentLanguage.displayName)
                        .font(.custom("Inter", size: 13))
                        .fontWeight(.medium)
                        .foregroundColor(colors.primaryText)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(colors.secondaryText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(colors.background)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(colors.border, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 主题选择行
struct ThemePickerRow: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    let colors: ThemeColors

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(languageManager.localized(.appearance))
                    .font(.custom("Outfit", size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(colors.primaryText)

                Text(languageManager.localized(.appearanceDesc))
                    .font(.custom("Inter", size: 13))
                    .foregroundColor(colors.secondaryText)
            }

            Spacer()

            HStack(spacing: 8) {
                ForEach(AppTheme.allCases) { theme in
                    ThemeButton(
                        theme: theme,
                        isSelected: themeManager.currentTheme == theme,
                        colors: colors
                    ) {
                        themeManager.currentTheme = theme
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 主题按钮
struct ThemeButton: View {
    let theme: AppTheme
    let isSelected: Bool
    let colors: ThemeColors
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.system(size: 12))

                Text(theme.displayName)
                    .font(.custom("Inter", size: 12))
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? colors.sidebarSelectedText : colors.primaryText)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? colors.sidebarSelectedBackground : colors.background)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Color.clear : colors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var iconName: String {
        switch theme {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }
}

// MARK: - 设置开关行
struct SettingToggleRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    let colors: ThemeColors

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Outfit", size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(colors.primaryText)

                Text(description)
                    .font(.custom("Inter", size: 13))
                    .foregroundColor(colors.secondaryText)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .labelsHidden()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 设置下拉行
struct SettingDropdownRow: View {
    let title: String
    let description: String
    let options: [String]
    @Binding var selected: String
    let colors: ThemeColors

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Outfit", size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(colors.primaryText)

                Text(description)
                    .font(.custom("Inter", size: 13))
                    .foregroundColor(colors.secondaryText)
            }

            Spacer()

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
                        .foregroundColor(colors.primaryText)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(colors.secondaryText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(colors.background)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(colors.border, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 快捷键设置行
struct ShortcutSettingRow: View {
    let title: String
    let description: String
    let shortcut: String
    let colors: ThemeColors

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Outfit", size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(colors.primaryText)

                Text(description)
                    .font(.custom("Inter", size: 13))
                    .foregroundColor(colors.secondaryText)
            }

            Spacer()

            Text(shortcut)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(colors.primaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(colors.background)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(colors.border, lineWidth: 1)
                )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
