import SwiftUI

// MARK: - 快捷键内容视图
struct ShortcutsContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 页面标题
                VStack(alignment: .leading, spacing: 8) {
                    Text("快捷键")
                        .font(.custom("Outfit", size: 28))
                        .fontWeight(.bold)
                        .kerning(-1)
                        .foregroundColor(.black)

                    Text("配置全局快捷键")
                        .font(.custom("Inter", size: 14))
                        .foregroundColor(Color(hex: "71717A"))
                }

                // 快捷键内容
                VStack(alignment: .leading, spacing: 16) {
                    Text("全局快捷键")
                        .font(.custom("Outfit", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    // 开始/停止录音
                    ShortcutRecorderRow(
                        title: "开始/停止录音",
                        description: "按下快捷键开始或停止语音转写",
                        shortcutName: .toggleRecording
                    )

                    // 暂停/继续录音
                    ShortcutRecorderRow(
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

// MARK: - 快捷键录制行
struct ShortcutRecorderRow: View {
    let title: String
    let description: String
    let shortcutName: ShortcutName

    @State private var shortcut: GlobalShortcut

    init(title: String, description: String, shortcutName: ShortcutName) {
        self.title = title
        self.description = description
        self.shortcutName = shortcutName
        self._shortcut = State(initialValue: GlobalShortcutManager.shared.getShortcut(shortcutName))
    }

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
            Text(shortcut.displayString)
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

// MARK: - 快捷键行 (静态显示，保留给其他地方使用)
struct ShortcutRow: View {
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
