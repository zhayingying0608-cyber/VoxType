import SwiftUI

// MARK: - 翻译内容视图
struct TranslateContentView: View {
    @State private var sourceLanguage = "简体中文"
    @State private var targetLanguage = "English"
    @State private var autoDetectLanguage = true
    @State private var showOriginalText = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 页面标题
                VStack(alignment: .leading, spacing: 8) {
                    Text("翻译")
                        .font(.custom("Outfit", size: 28))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)

                    Text("实时语音翻译，跨越语言障碍")
                        .font(.custom("Inter", size: 14))
                        .foregroundColor(Color(hex: "71717A"))
                }

                // 语言设置
                LanguageSection(
                    sourceLanguage: $sourceLanguage,
                    targetLanguage: $targetLanguage
                )

                // 翻译设置
                TranslateSettingsSection(
                    autoDetectLanguage: $autoDetectLanguage,
                    showOriginalText: $showOriginalText
                )

                Spacer()
            }
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

// MARK: - 语言设置区块
struct LanguageSection: View {
    @Binding var sourceLanguage: String
    @Binding var targetLanguage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("语言设置")
                .font(.custom("Outfit", size: 16))
                .fontWeight(.bold)
                .foregroundColor(.black)

            HStack(spacing: 16) {
                // 源语言
                LanguageSelector(
                    label: "源语言",
                    selectedLanguage: $sourceLanguage
                )

                // 交换按钮
                Button(action: {
                    let temp = sourceLanguage
                    sourceLanguage = targetLanguage
                    targetLanguage = temp
                }) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                // 目标语言
                LanguageSelector(
                    label: "目标语言",
                    selectedLanguage: $targetLanguage
                )
            }
            .padding(16)
            .background(Color(hex: "F4F4F5"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - 语言选择器
struct LanguageSelector: View {
    let label: String
    @Binding var selectedLanguage: String

    let languages = ["简体中文", "English", "日本語", "한국어", "Français", "Deutsch", "Español"]

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.custom("Inter", size: 12))
                .foregroundColor(Color(hex: "71717A"))

            Menu {
                ForEach(languages, id: \.self) { language in
                    Button(language) {
                        selectedLanguage = language
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(selectedLanguage)
                        .font(.custom("Inter", size: 15))
                        .fontWeight(.medium)
                        .foregroundColor(.black)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "71717A"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 翻译设置区块
struct TranslateSettingsSection: View {
    @Binding var autoDetectLanguage: Bool
    @Binding var showOriginalText: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("翻译设置")
                .font(.custom("Outfit", size: 16))
                .fontWeight(.bold)
                .foregroundColor(.black)

            // 自动检测语言
            TranslateSettingToggleRow(
                title: "自动检测语言",
                description: "自动识别输入内容的语言",
                isOn: $autoDetectLanguage
            )

            // 显示原文
            TranslateSettingToggleRow(
                title: "显示原文",
                description: "翻译结果同时显示原文内容",
                isOn: $showOriginalText
            )
        }
    }
}

// MARK: - 设置开关行
struct TranslateSettingToggleRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool

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

            Toggle("", isOn: $isOn)
                .toggleStyle(CustomToggleStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(hex: "F4F4F5"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 自定义开关样式
struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(configuration.isOn ? Color.black : Color(hex: "E4E4E7"))
                .frame(width: 44, height: 24)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .offset(x: configuration.isOn ? 10 : -10)
                        .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                )
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}
