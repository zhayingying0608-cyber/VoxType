import SwiftUI
import AppKit

// MARK: - 历史记录内容视图
struct HistoryContentView: View {
    @ObservedObject private var historyManager = HistoryManager.shared
    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedFilter = "all"
    @State private var searchText = ""
    @State private var showClearAlert = false

    private var colors: ThemeColors {
        ThemeColors(theme: themeManager.currentTheme, systemColorScheme: colorScheme)
    }

    private var filteredRecords: [TranscriptionRecord] {
        var records = historyManager.records

        // 按时间筛选
        let calendar = Calendar.current
        let now = Date()

        switch selectedFilter {
        case "today":
            records = records.filter { calendar.isDateInToday($0.timestamp) }
        case "week":
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            records = records.filter { $0.timestamp >= weekAgo }
        case "month":
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            records = records.filter { $0.timestamp >= monthAgo }
        default:
            break
        }

        // 按搜索词筛选
        if !searchText.isEmpty {
            records = records.filter { $0.text.localizedCaseInsensitiveContains(searchText) }
        }

        return records
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 页面标题和搜索
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(languageManager.localized(.history))
                            .font(.custom("Outfit", size: 28))
                            .fontWeight(.bold)
                            .kerning(-1)
                            .foregroundColor(colors.primaryText)

                        Text(languageManager.localized(.historyDesc))
                            .font(.custom("Inter", size: 14))
                            .foregroundColor(colors.secondaryText)
                    }

                    Spacer()

                    // 搜索框
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16))
                            .foregroundColor(colors.secondaryText)

                        TextField("搜索...", text: $searchText)
                            .font(.custom("Inter", size: 13))
                            .textFieldStyle(.plain)
                            .foregroundColor(colors.primaryText)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(colors.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 220)
                }

                // 筛选和清空按钮
                HStack(spacing: 8) {
                    FilterChip(title: filterTitle("all"), isSelected: selectedFilter == "all") {
                        selectedFilter = "all"
                    }
                    FilterChip(title: filterTitle("today"), isSelected: selectedFilter == "today") {
                        selectedFilter = "today"
                    }
                    FilterChip(title: filterTitle("week"), isSelected: selectedFilter == "week") {
                        selectedFilter = "week"
                    }
                    FilterChip(title: filterTitle("month"), isSelected: selectedFilter == "month") {
                        selectedFilter = "month"
                    }

                    Spacer()

                    if !historyManager.records.isEmpty {
                        Button(action: { showClearAlert = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "trash")
                                    .font(.system(size: 12))
                                Text(languageManager.localized(.clearHistory))
                                    .font(.custom("Inter", size: 12))
                            }
                            .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // 记录列表
                if filteredRecords.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.badge.questionmark")
                            .font(.system(size: 48))
                            .foregroundColor(colors.secondaryText.opacity(0.5))

                        Text(languageManager.localized(.noHistory))
                            .font(.custom("Inter", size: 15))
                            .foregroundColor(colors.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    VStack(spacing: 12) {
                        ForEach(filteredRecords) { record in
                            HistoryRecordRow(record: record, colors: colors) {
                                historyManager.deleteRecord(record)
                            }
                        }
                    }
                }
            }
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colors.background)
        .alert("确认清空", isPresented: $showClearAlert) {
            Button("取消", role: .cancel) {}
            Button("清空", role: .destructive) {
                historyManager.clearAll()
            }
        } message: {
            Text("确定要清空所有历史记录吗？此操作不可撤销。")
        }
    }

    private func filterTitle(_ key: String) -> String {
        switch key {
        case "all":
            return languageManager.currentLanguage == .en ? "All" :
                   languageManager.currentLanguage == .ja ? "すべて" : "全部"
        case "today":
            return languageManager.currentLanguage == .en ? "Today" :
                   languageManager.currentLanguage == .ja ? "今日" : "今天"
        case "week":
            return languageManager.currentLanguage == .en ? "This Week" :
                   languageManager.currentLanguage == .ja ? "今週" : "本周"
        case "month":
            return languageManager.currentLanguage == .en ? "This Month" :
                   languageManager.currentLanguage == .ja ? "今月" : "本月"
        default:
            return key
        }
    }
}

// MARK: - 筛选按钮
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.colorScheme) private var colorScheme

    private var colors: ThemeColors {
        ThemeColors(theme: themeManager.currentTheme, systemColorScheme: colorScheme)
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Inter", size: 13))
                .fontWeight(.medium)
                .foregroundColor(isSelected ? colors.sidebarSelectedText : colors.primaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? colors.sidebarSelectedBackground : colors.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 历史记录行
struct HistoryRecordRow: View {
    let record: TranscriptionRecord
    let colors: ThemeColors
    let onDelete: () -> Void

    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 顶部信息
            HStack {
                Text(record.formattedDate)
                    .font(.custom("Inter", size: 12))
                    .foregroundColor(colors.secondaryText)

                if let duration = record.formattedDuration {
                    Text("•")
                        .foregroundColor(colors.secondaryText)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text(duration)
                            .font(.custom("Inter", size: 12))
                    }
                    .foregroundColor(colors.secondaryText)
                }

                Spacer()

                // 操作按钮
                if isHovered {
                    HStack(spacing: 8) {
                        Button(action: copyToClipboard) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 12))
                                .foregroundColor(colors.secondaryText)
                        }
                        .buttonStyle(.plain)
                        .help("复制")

                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.system(size: 12))
                                .foregroundColor(.red.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                        .help("删除")
                    }
                }
            }

            // 文本内容
            Text(record.text)
                .font(.custom("Inter", size: 14))
                .foregroundColor(colors.primaryText)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }

    private func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(record.text, forType: .string)
    }
}
