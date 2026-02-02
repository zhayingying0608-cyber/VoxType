import SwiftUI

// MARK: - 手机配对内容视图
struct PhonePairingContentView: View {
    @State private var pairCode = ["A", "B", "C", "D"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 页面标题
                VStack(alignment: .leading, spacing: 8) {
                    Text("手机配对")
                        .font(.custom("Outfit", size: 28))
                        .fontWeight(.bold)
                        .kerning(-1)
                        .foregroundColor(.black)

                    Text("实现跨屏语音输入：手机采集语音，实时转为Mac屏幕上的文字")
                        .font(.custom("Inter", size: 15))
                        .foregroundColor(Color(hex: "71717A"))
                }

                // 主内容区域
                HStack(alignment: .top, spacing: 48) {
                    // 左侧：二维码区域
                    VStack(spacing: 24) {
                        // 二维码占位
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "F4F4F5"))
                            .frame(width: 200, height: 200)
                            .overlay(
                                Image(systemName: "qrcode")
                                    .font(.system(size: 80))
                                    .foregroundColor(Color(hex: "A1A1AA"))
                            )

                        Text("使用 iPhone 扫描配对")
                            .font(.custom("Inter", size: 13))
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: "71717A"))

                        // 分隔线
                        HStack(spacing: 12) {
                            Rectangle()
                                .fill(Color(hex: "E4E4E7"))
                                .frame(height: 1)

                            Text("或手动输入")
                                .font(.custom("Inter", size: 13))
                                .foregroundColor(Color(hex: "A1A1AA"))

                            Rectangle()
                                .fill(Color(hex: "E4E4E7"))
                                .frame(height: 1)
                        }
                        .frame(maxWidth: .infinity)

                        // 配对码
                        HStack(spacing: 8) {
                            ForEach(0..<4, id: \.self) { index in
                                Text(pairCode[index])
                                    .font(.custom("Outfit", size: 24))
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                    .frame(width: 48, height: 48)
                                    .background(Color(hex: "F4F4F5"))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // 右侧：配对步骤
                    VStack(alignment: .leading, spacing: 20) {
                        Text("配对步骤")
                            .font(.custom("Outfit", size: 18))
                            .fontWeight(.bold)
                            .foregroundColor(.black)

                        // 步骤 1
                        PairingStepRow(
                            number: "1",
                            title: "下载 VoxType iOS App",
                            description: "在 App Store 搜索 VoxType 并安装"
                        )

                        // 步骤 2
                        PairingStepRow(
                            number: "2",
                            title: "打开 App 并选择配对",
                            description: "点击底部「配对」标签页"
                        )

                        // 步骤 3
                        PairingStepRow(
                            number: "3",
                            title: "扫描二维码或输入配对码",
                            description: "确保手机和 Mac 在同一 WiFi 网络下"
                        )

                        // 提示框
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "71717A"))

                            Text("配对后，手机会作为 Mac 的无线麦克风，说话内容会实时转成文字显示。")
                                .font(.custom("Inter", size: 13))
                                .foregroundColor(Color(hex: "71717A"))
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(hex: "F4F4F5"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

// MARK: - 配对步骤行
struct PairingStepRow: View {
    let number: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 步骤编号
            Text(number)
                .font(.custom("Outfit", size: 14))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.black)
                .clipShape(Circle())

            // 步骤内容
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Outfit", size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)

                Text(description)
                    .font(.custom("Inter", size: 13))
                    .foregroundColor(Color(hex: "71717A"))
            }
        }
    }
}
