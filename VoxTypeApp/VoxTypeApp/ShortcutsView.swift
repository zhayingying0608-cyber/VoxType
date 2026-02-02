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

                    Text("两种方式触发语音转写")
                        .font(.custom("Inter", size: 14))
                        .foregroundColor(Color(hex: "71717A"))
                }

                // 快捷键内容
                VStack(alignment: .leading, spacing: 16) {
                    Text("全局快捷键")
                        .font(.custom("Outfit", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    // 长按 Option
                    ShortcutDisplayRow(
                        title: "长按 Option",
                        description: "按住 Option 键开始录音，松开自动停止并转写",
                        shortcut: "⌥ 长按"
                    )

                    // 双击 Shift
                    ShortcutDisplayRow(
                        title: "双击 Shift",
                        description: "快速双击 Shift 键切换录音状态",
                        shortcut: "⇧⇧"
                    )
                }

                // 使用说明
                VStack(alignment: .leading, spacing: 12) {
                    Text("使用说明")
                        .font(.custom("Outfit", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 12) {
                            Text("1.")
                                .font(.custom("Inter", size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: "71717A"))
                            Text("长按模式：按住 Option 键说话，松开后自动转写并粘贴")
                                .font(.custom("Inter", size: 14))
                                .foregroundColor(.black)
                        }

                        HStack(alignment: .top, spacing: 12) {
                            Text("2.")
                                .font(.custom("Inter", size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: "71717A"))
                            Text("切换模式：双击 Shift 开始录音，再双击停止录音")
                                .font(.custom("Inter", size: 14))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(16)
                    .background(Color(hex: "F4F4F5"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

// MARK: - 快捷键显示行
struct ShortcutDisplayRow: View {
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

            Text(shortcut)
                .font(.system(size: 14, weight: .medium, design: .rounded))
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
