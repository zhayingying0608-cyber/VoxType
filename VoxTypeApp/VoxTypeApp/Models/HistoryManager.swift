import Foundation

/// 转写记录
struct TranscriptionRecord: Identifiable, Codable {
    let id: UUID
    let text: String
    let timestamp: Date
    let duration: TimeInterval? // 录音时长（秒）

    init(text: String, duration: TimeInterval? = nil) {
        self.id = UUID()
        self.text = text
        self.timestamp = Date()
        self.duration = duration
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    var formattedDuration: String? {
        guard let duration = duration else { return nil }
        let seconds = Int(duration)
        if seconds < 60 {
            return "\(seconds)s"
        } else {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return "\(minutes)m \(remainingSeconds)s"
        }
    }

    var preview: String {
        if text.count <= 50 {
            return text
        }
        return String(text.prefix(50)) + "..."
    }
}

/// 历史记录管理器
@MainActor
final class HistoryManager: ObservableObject {
    static let shared = HistoryManager()

    @Published private(set) var records: [TranscriptionRecord] = []

    private let maxRecords = 100
    private let storageKey = "transcriptionHistory"

    private init() {
        loadRecords()
    }

    /// 添加记录
    func addRecord(text: String, duration: TimeInterval? = nil) {
        guard !text.isEmpty else { return }

        let record = TranscriptionRecord(text: text, duration: duration)
        records.insert(record, at: 0)

        // 限制最大记录数
        if records.count > maxRecords {
            records = Array(records.prefix(maxRecords))
        }

        saveRecords()
    }

    /// 删除记录
    func deleteRecord(_ record: TranscriptionRecord) {
        records.removeAll { $0.id == record.id }
        saveRecords()
    }

    /// 删除指定索引的记录
    func deleteRecord(at indexSet: IndexSet) {
        records.remove(atOffsets: indexSet)
        saveRecords()
    }

    /// 清空所有记录
    func clearAll() {
        records.removeAll()
        saveRecords()
    }

    /// 保存记录
    private func saveRecords() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    /// 加载记录
    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([TranscriptionRecord].self, from: data) {
            records = decoded
        }
    }
}
