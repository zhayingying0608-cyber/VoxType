import SwiftUI

// MARK: - 转录文件内容视图
struct FilesContentView: View {
    @State private var selectedFilter = "全部"
    @State private var searchText = ""

    let filters = ["全部", "今天", "本周", "本月"]

    let files = [
        FileRecord(name: "会议记录_20240115", date: "2024-01-15", duration: "32:15", size: "1.2 MB"),
        FileRecord(name: "采访录音_张三", date: "2024-01-14", duration: "45:30", size: "2.1 MB"),
        FileRecord(name: "课堂笔记_机器学习", date: "2024-01-13", duration: "58:22", size: "2.8 MB"),
        FileRecord(name: "产品讨论会", date: "2024-01-12", duration: "28:45", size: "1.0 MB")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 页面标题和搜索
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("转录文件")
                            .font(.custom("Outfit", size: 28))
                            .fontWeight(.bold)
                            .kerning(-1)
                            .foregroundColor(.black)

                        Text("管理所有转录的音频文件")
                            .font(.custom("Inter", size: 14))
                            .foregroundColor(Color(hex: "71717A"))
                    }

                    Spacer()

                    // 搜索框
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "A1A1AA"))

                        TextField("搜索文件...", text: $searchText)
                            .font(.custom("Inter", size: 13))
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(hex: "F4F4F5"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 220)
                }

                // 文件内容
                VStack(spacing: 16) {
                    // 筛选标签
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.self) { filter in
                            FilesFilterButton(
                                title: filter,
                                isSelected: selectedFilter == filter
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }

                    // 文件列表
                    VStack(spacing: 12) {
                        ForEach(files) { file in
                            FileRow(file: file)
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

// MARK: - 文件记录
struct FileRecord: Identifiable {
    let id = UUID()
    let name: String
    let date: String
    let duration: String
    let size: String
}

// MARK: - 筛选按钮
struct FilesFilterButton: View {
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

// MARK: - 文件行
struct FileRow: View {
    let file: FileRecord

    var body: some View {
        HStack {
            // 文件图标
            Image(systemName: "doc.text")
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "71717A"))
                .frame(width: 40, height: 40)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // 文件信息
            VStack(alignment: .leading, spacing: 4) {
                Text(file.name)
                    .font(.custom("Outfit", size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)

                HStack(spacing: 12) {
                    Text(file.date)
                        .font(.custom("Inter", size: 12))
                        .foregroundColor(Color(hex: "71717A"))

                    Text(file.duration)
                        .font(.custom("Inter", size: 12))
                        .foregroundColor(Color(hex: "71717A"))

                    Text(file.size)
                        .font(.custom("Inter", size: 12))
                        .foregroundColor(Color(hex: "71717A"))
                }
            }

            Spacer()

            // 操作按钮
            HStack(spacing: 8) {
                IconButton(icon: "eye")
                IconButton(icon: "square.and.arrow.up")
                IconButton(icon: "trash")
            }
        }
        .padding(16)
        .background(Color(hex: "F4F4F5"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 图标按钮
struct IconButton: View {
    let icon: String

    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "71717A"))
                .frame(width: 32, height: 32)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
}
