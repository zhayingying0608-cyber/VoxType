import SwiftUI

/// 主题模式
enum AppTheme: String, CaseIterable, Identifiable {
    case light = "light"
    case dark = "dark"
    case system = "system"

    var id: String { rawValue }

    var displayName: String {
        // 直接使用存储的语言设置，避免 MainActor 隔离问题
        let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "zh-Hans"
        let language = AppLanguage(rawValue: savedLanguage) ?? .zhHans

        switch self {
        case .light:
            return LocalizedKey.lightMode.string(for: language)
        case .dark:
            return LocalizedKey.darkMode.string(for: language)
        case .system:
            return LocalizedKey.systemMode.string(for: language)
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

/// 主题管理器
@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "appTheme")
        }
    }

    private init() {
        if let saved = UserDefaults.standard.string(forKey: "appTheme"),
           let theme = AppTheme(rawValue: saved) {
            currentTheme = theme
        } else {
            currentTheme = .system
        }
    }

    /// 获取当前颜色方案
    var colorScheme: ColorScheme? {
        currentTheme.colorScheme
    }
}

/// 主题颜色
struct ThemeColors {
    let theme: AppTheme
    let systemColorScheme: ColorScheme

    private var isDark: Bool {
        switch theme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }

    // 背景色
    var background: Color {
        isDark ? Color(hex: "1C1C1E") : Color.white
    }

    var secondaryBackground: Color {
        isDark ? Color(hex: "2C2C2E") : Color(hex: "F4F4F5")
    }

    var tertiaryBackground: Color {
        isDark ? Color(hex: "3A3A3C") : Color(hex: "E4E4E7")
    }

    // 文字色
    var primaryText: Color {
        isDark ? Color.white : Color.black
    }

    var secondaryText: Color {
        isDark ? Color(hex: "A1A1AA") : Color(hex: "71717A")
    }

    // 边框色
    var border: Color {
        isDark ? Color(hex: "3A3A3C") : Color(hex: "E4E4E7")
    }

    // 强调色
    var accent: Color {
        Color.blue
    }

    // 侧边栏
    var sidebarBackground: Color {
        isDark ? Color(hex: "2C2C2E") : Color(hex: "F4F4F5")
    }

    var sidebarSelectedBackground: Color {
        isDark ? Color.white : Color.black
    }

    var sidebarSelectedText: Color {
        isDark ? Color.black : Color.white
    }
}

/// 主题环境键
struct ThemeColorsKey: EnvironmentKey {
    static let defaultValue = ThemeColors(theme: .system, systemColorScheme: .light)
}

extension EnvironmentValues {
    var themeColors: ThemeColors {
        get { self[ThemeColorsKey.self] }
        set { self[ThemeColorsKey.self] = newValue }
    }
}
