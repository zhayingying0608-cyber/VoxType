import SwiftUI

// MARK: - 历史记录内容视图
struct HistoryContentView: View {
    @State private var selectedFilter = "全部"
    @State private var searchText = ""

    let filters = ["全部", "今天", "本周", "本月"]

    let records = [
        HistoryRecord(
            title: "产品需求讨论会议",
            preview: "今天我们主要讨论一下新版本的功能需求，首先是用户反馈最多的几个问题...",
            date: "今天 14:32",
            duration: "32:15"
        ),
        HistoryRecord(
            title: "技术方案评审",
            preview: "关于这个技术方案，我有几点建议。第一，我们需要考虑系统的可扩展性...",
            date: "今天 10:15",
            duration: "45:30"
        ),
        HistoryRecord(
            title: "用户访谈记录",
            preview: "您好，感谢您抽出时间参与我们的用户访谈。首先想了解一下您使用我们产品的频率...",
            date: "昨天 16:20",
            duration: "28:45"
        ),
        HistoryRecord(
            title: "周会纪要",
            preview: "本周工作总结：1. 完成了新功能的开发和测试 2. 修复了用户反馈的几个 bug...",
            date: "昨天 09:00",
            duration: "58:22"
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 页面标题和搜索
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("历史记录")
                            .font(.custom("Outfit", size: 28))
                            .fontWeight(.bold)
                            .kerning(-1)
                            .foregroundColor(.black)

                        Text("查看和管理所有转写记录")
                            .font(.custom("Inter", size: 14))
                            .foregroundColor(Color(hex: "71717A"))
                    }

                    Spacer()

                    // 搜索框
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "A1A1AA"))

                        TextField("搜索记录...", text: $searchText)
                            .font(.custom("Inter", size: 13))
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(hex: "F4F4F5"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 220)
                }

                // 历史内容
                VStack(spacing: 16) {
                    // 筛选标签
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.self) { filter in
                            FilterButton(
                                title: filter,
                                isSelected: selectedFilter == filter
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }

                    // 记录列表
                    VStack(spacing: 12) {
                        ForEach(records) { record in
                            HistoryRow(record: record)
                        }
                    }
                }
            }
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

// MARK: - 历史记录
struct HistoryRecord: Identifiable {
    let id = UUID()
    let title: String
    let preview: String
    let date: String
    let duration: String
}

// MARK: - 历史记录行
struct HistoryRow: View {
    let record: HistoryRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 标题行
            HStack {
                Text(record.title)
                    .font(.custom("Outfit", size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)

                Spacer()

                Text(record.date)
                    .font(.custom("Inter", size: 12))
                    .foregroundColor(Color(hex: "A1A1AA"))
            }

            // 预览文本
            Text(record.preview)
                .font(.custom("Inter", size: 13))
                .foregroundColor(Color(hex: "71717A"))
                .lineLimit(2)

            // 底部信息
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "A1A1AA"))

                    Text(record.duration)
                        .font(.custom("Inter", size: 12))
                        .foregroundColor(Color(hex: "A1A1AA"))
                }

                Spacer()

                // 操作按钮
                HStack(spacing: 8) {
                    SmallIconButton(icon: "doc.on.doc")
                    SmallIconButton(icon: "square.and.arrow.up")
                    SmallIconButton(icon: "trash")
                }
            }
        }
        .padding(16)
        .background(Color(hex: "F4F4F5"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 小图标按钮
struct SmallIconButton: View {
    let icon: String

    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "71717A"))
        }
        .buttonStyle(.plain)
    }
}
