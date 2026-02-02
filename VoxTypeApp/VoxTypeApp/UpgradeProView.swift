import SwiftUI

// MARK: - 升级 Pro 内容视图
struct UpgradeProContentView: View {
    @State private var selectedPlan = "yearly"

    let features = [
        ProFeature(icon: "waveform", title: "Large-v3 模型"),
        ProFeature(icon: "sparkles", title: "AI 润色功能"),
        ProFeature(icon: "iphone.and.arrow.forward", title: "手机配对"),
        ProFeature(icon: "infinity", title: "无限转写时长")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Pro 徽章
                HStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)

                    Text("VoxType Pro")
                        .font(.custom("Outfit", size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                // 标题
                Text("解锁全部高级功能")
                    .font(.custom("Outfit", size: 32))
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                Text("获得更强大的模型、AI 润色、跨设备协同等专业功能")
                    .font(.custom("Inter", size: 16))
                    .foregroundColor(Color(hex: "71717A"))
                    .multilineTextAlignment(.center)

                // 价格卡片
                HStack(spacing: 24) {
                    // 月付
                    PriceCard(
                        title: "月付",
                        price: "¥28",
                        period: "/月",
                        isSelected: selectedPlan == "monthly",
                        isPopular: false
                    ) {
                        selectedPlan = "monthly"
                    }

                    // 年付
                    PriceCard(
                        title: "年付",
                        price: "¥198",
                        period: "/年",
                        isSelected: selectedPlan == "yearly",
                        isPopular: true,
                        savings: "省 ¥138"
                    ) {
                        selectedPlan = "yearly"
                    }
                }

                // 功能列表
                VStack(spacing: 12) {
                    Text("Pro 版专属功能")
                        .font(.custom("Inter", size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)

                    HStack(spacing: 8) {
                        ForEach(features) { feature in
                            ProFeatureTag(feature: feature)
                        }
                    }
                }
            }
            .frame(width: 500)
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

// MARK: - Pro 功能
struct ProFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
}

// MARK: - 价格卡片
struct PriceCard: View {
    let title: String
    let price: String
    let period: String
    let isSelected: Bool
    let isPopular: Bool
    var savings: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                if isPopular {
                    Text("最受欢迎")
                        .font(.custom("Inter", size: 11))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(hex: "22C55E"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Spacer().frame(height: 22)
                }

                Text(title)
                    .font(.custom("Outfit", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .black)

                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(price)
                        .font(.custom("Outfit", size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(isSelected ? .white : .black)

                    Text(period)
                        .font(.custom("Inter", size: 14))
                        .foregroundColor(isSelected ? Color.white.opacity(0.7) : Color(hex: "71717A"))
                }

                if let savings = savings {
                    Text(savings)
                        .font(.custom("Inter", size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? Color.white.opacity(0.8) : Color(hex: "22C55E"))
                } else {
                    Spacer().frame(height: 16)
                }

                // 订阅按钮
                Text("立即订阅")
                    .font(.custom("Outfit", size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .black : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(isSelected ? Color.white : Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(24)
            .frame(width: 200, height: 220)
            .background(isSelected ? Color.black : Color(hex: "D6D6D6").opacity(0.58))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Pro 功能标签
struct ProFeatureTag: View {
    let feature: ProFeature

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: feature.icon)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "71717A"))

            Text(feature.title)
                .font(.custom("Inter", size: 12))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(hex: "F4F4F5"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
