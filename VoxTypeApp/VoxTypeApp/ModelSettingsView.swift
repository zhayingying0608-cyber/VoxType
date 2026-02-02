import SwiftUI

// MARK: - 听写模型内容视图
struct ModelSettingsContentView: View {
    @State private var selectedModel = "small"

    let models = [
        ModelInfo(id: "tiny", name: "Tiny", size: "39MB", speed: "极快", accuracy: "基础"),
        ModelInfo(id: "base", name: "Base", size: "74MB", speed: "快", accuracy: "较好"),
        ModelInfo(id: "small", name: "Small", size: "244MB", speed: "中等", accuracy: "好"),
        ModelInfo(id: "medium", name: "Medium", size: "769MB", speed: "较慢", accuracy: "很好"),
        ModelInfo(id: "large-v3", name: "Large-v3", size: "1550MB", speed: "慢", accuracy: "最佳"),
        ModelInfo(id: "turbo", name: "Turbo", size: "809MB", speed: "快", accuracy: "很好")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 页面标题
                VStack(alignment: .leading, spacing: 8) {
                    Text("听写模型")
                        .font(.custom("Outfit", size: 28))
                        .fontWeight(.bold)
                        .kerning(-1)
                        .foregroundColor(.black)

                    Text("选择语音识别模型，平衡速度与精度")
                        .font(.custom("Inter", size: 14))
                        .foregroundColor(Color(hex: "71717A"))
                }

                // 模型网格
                VStack(spacing: 16) {
                    // 第一行
                    HStack(spacing: 12) {
                        ForEach(models.prefix(3)) { model in
                            ModelCard(model: model, isSelected: selectedModel == model.id) {
                                selectedModel = model.id
                            }
                        }
                    }

                    // 第二行
                    HStack(spacing: 12) {
                        ForEach(models.suffix(3)) { model in
                            ModelCard(model: model, isSelected: selectedModel == model.id) {
                                selectedModel = model.id
                            }
                        }
                    }

                    // 提示框
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "71717A"))

                        Text("small 模型是日常使用的最佳平衡，如需专业级精度可选择 large-v3-turbo")
                            .font(.custom("Inter", size: 13))
                            .foregroundColor(Color(hex: "71717A"))
                            .lineSpacing(4)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
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

// MARK: - 模型信息
struct ModelInfo: Identifiable {
    let id: String
    let name: String
    let size: String
    let speed: String
    let accuracy: String
}

// MARK: - 模型卡片
struct ModelCard: View {
    let model: ModelInfo
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Text(model.name)
                    .font(.custom("Outfit", size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                VStack(alignment: .leading, spacing: 4) {
                    ModelInfoRow(label: "大小", value: model.size)
                    ModelInfoRow(label: "速度", value: model.speed)
                    ModelInfoRow(label: "精度", value: model.accuracy)
                }
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

// MARK: - 模型信息行
struct ModelInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.custom("Inter", size: 12))
                .foregroundColor(Color(hex: "71717A"))

            Spacer()

            Text(value)
                .font(.custom("Inter", size: 12))
                .fontWeight(.medium)
                .foregroundColor(.black)
        }
    }
}
