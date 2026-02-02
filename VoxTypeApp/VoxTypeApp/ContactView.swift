import SwiftUI

// MARK: - 联系我们内容视图
struct ContactContentView: View {
    @State private var feedbackType = "功能建议"
    @State private var feedbackContent = ""

    let feedbackTypes = ["功能建议", "Bug 反馈", "其他"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 页面标题
                Text("联系我们")
                    .font(.custom("Outfit", size: 28))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)

                Text("如有问题或建议，欢迎通过以下方式联系我们")
                    .font(.custom("Inter", size: 14))
                    .foregroundColor(Color(hex: "71717A"))

                Spacer().frame(height: 8)

                // 联系卡片
                VStack(spacing: 16) {
                    ContactCard(
                        icon: "envelope.fill",
                        title: "邮件联系",
                        value: "support@voxtype.app",
                        description: "工作日 24 小时内回复"
                    )

                    ContactCard(
                        icon: "link",
                        title: "GitHub",
                        value: "github.com/voxtype",
                        description: "查看源码和提交 Issue"
                    )

                    ContactCard(
                        icon: "bubble.left.fill",
                        title: "Twitter",
                        value: "@VoxTypeApp",
                        description: "获取最新动态和更新"
                    )
                }

                Spacer().frame(height: 16)

                // 意见反馈
                VStack(alignment: .leading, spacing: 16) {
                    Text("意见反馈")
                        .font(.custom("Outfit", size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)

                    Text("您的反馈对我们非常重要，帮助我们不断改进产品")
                        .font(.custom("Inter", size: 14))
                        .foregroundColor(Color(hex: "71717A"))

                    // 反馈表单
                    VStack(alignment: .leading, spacing: 12) {
                        Text("反馈类型")
                            .font(.custom("Inter", size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(.black)

                        // 类型选择
                        HStack(spacing: 8) {
                            ForEach(feedbackTypes, id: \.self) { type in
                                FeedbackTypeButton(
                                    title: type,
                                    isSelected: feedbackType == type
                                ) {
                                    feedbackType = type
                                }
                            }
                        }

                        Text("反馈内容")
                            .font(.custom("Inter", size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(.black)

                        // 内容输入
                        TextEditor(text: $feedbackContent)
                            .font(.custom("Inter", size: 13))
                            .frame(height: 100)
                            .padding(12)
                            .background(Color(hex: "F4F4F5"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        // 提交按钮
                        Button(action: {}) {
                            Text("提交反馈")
                                .font(.custom("Outfit", size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(20)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Spacer().frame(height: 16)

                // 常见问题
                VStack(alignment: .leading, spacing: 12) {
                    Text("常见问题")
                        .font(.custom("Outfit", size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)

                    FAQRow(question: "如何解决语音识别不准确的问题？")
                    FAQRow(question: "Pro 版本与免费版有什么区别？")
                }
            }
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

// MARK: - 联系卡片
struct ContactCard: View {
    let icon: String
    let title: String
    let value: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            // 图标
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "71717A"))
                .frame(width: 48, height: 48)
                .background(Color(hex: "F4F4F5"))
                .clipShape(RoundedRectangle(cornerRadius: 24))

            // 内容
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Outfit", size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)

                Text(value)
                    .font(.custom("Inter", size: 13))
                    .foregroundColor(Color(hex: "71717A"))
            }

            Spacer()

            Text(description)
                .font(.custom("Inter", size: 12))
                .foregroundColor(Color(hex: "A1A1AA"))
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 反馈类型按钮
struct FeedbackTypeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Inter", size: 13))
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.black : Color(hex: "F4F4F5"))
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - FAQ 行
struct FAQRow: View {
    let question: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "71717A"))

            Text(question)
                .font(.custom("Inter", size: 14))
                .foregroundColor(.black)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "A1A1AA"))
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
