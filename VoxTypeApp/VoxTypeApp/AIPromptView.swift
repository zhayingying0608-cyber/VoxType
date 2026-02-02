import SwiftUI

// MARK: - AI 提示词内容视图
struct AIPromptContentView: View {
    @State private var selectedPrompt = "polish"
    @State private var openAIKey = ""
    @State private var claudeKey = ""

    let prompts = [
        PromptTemplate(id: "polish", name: "润色优化", description: "优化文本表达，提升可读性", icon: "sparkles"),
        PromptTemplate(id: "summary", name: "摘要提取", description: "提取文本核心要点", icon: "doc.text"),
        PromptTemplate(id: "translate", name: "智能翻译", description: "高质量多语言翻译", icon: "globe"),
        PromptTemplate(id: "format", name: "格式化", description: "结构化整理文本内容", icon: "list.bullet")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 页面标题和新建按钮
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AI 提示词")
                            .font(.custom("Outfit", size: 28))
                            .fontWeight(.bold)
                            .kerning(-1)
                            .foregroundColor(.black)

                        Text("管理 AI 润色模板和云端模型配置")
                            .font(.custom("Inter", size: 14))
                            .foregroundColor(Color(hex: "71717A"))
                    }

                    Spacer()

                    // 新建模板按钮
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 14))
                                .foregroundColor(.white)

                            Text("新建模板")
                                .font(.custom("Outfit", size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }

                // AI 内容
                VStack(alignment: .leading, spacing: 24) {
                    // 预设模板
                    VStack(alignment: .leading, spacing: 16) {
                        Text("预设模板")
                            .font(.custom("Outfit", size: 16))
                            .fontWeight(.bold)
                            .foregroundColor(.black)

                        // 模板网格
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(prompts) { prompt in
                                PromptCard(
                                    prompt: prompt,
                                    isSelected: selectedPrompt == prompt.id
                                ) {
                                    selectedPrompt = prompt.id
                                }
                            }
                        }
                    }

                    // 云端模型配置
                    VStack(alignment: .leading, spacing: 16) {
                        Text("云端模型配置")
                            .font(.custom("Outfit", size: 16))
                            .fontWeight(.bold)
                            .foregroundColor(.black)

                        // OpenAI API
                        APIConfigRow(
                            name: "OpenAI",
                            placeholder: "sk-...",
                            value: $openAIKey
                        )

                        // Claude API
                        APIConfigRow(
                            name: "Claude",
                            placeholder: "sk-ant-...",
                            value: $claudeKey
                        )
                    }
                }
            }
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

// MARK: - 提示词模板
struct PromptTemplate: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
}

// MARK: - 提示词卡片
struct PromptCard: View {
    let prompt: PromptTemplate
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: prompt.icon)
                        .font(.system(size: 18))
                        .foregroundColor(isSelected ? .black : Color(hex: "71717A"))

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                }

                Text(prompt.name)
                    .font(.custom("Outfit", size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)

                Text(prompt.description)
                    .font(.custom("Inter", size: 12))
                    .foregroundColor(Color(hex: "71717A"))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.white : Color(hex: "F4F4F5"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.black : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - API 配置行
struct APIConfigRow: View {
    let name: String
    let placeholder: String
    @Binding var value: String

    var body: some View {
        HStack(spacing: 16) {
            Text(name)
                .font(.custom("Outfit", size: 14))
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(width: 80, alignment: .leading)

            TextField(placeholder, text: $value)
                .font(.custom("Inter", size: 13))
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(hex: "F4F4F5"))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
