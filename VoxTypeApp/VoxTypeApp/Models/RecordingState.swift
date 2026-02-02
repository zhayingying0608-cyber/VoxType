import Foundation
import Combine
import AppKit

/// 录音状态枚举
enum RecordingStatus: Equatable {
    case idle
    case recording
    case transcribing
    case error(String)

    var isRecording: Bool {
        self == .recording
    }

    var isProcessing: Bool {
        switch self {
        case .recording, .transcribing:
            return true
        default:
            return false
        }
    }
}

/// 录音状态管理器
@MainActor
final class RecordingState: ObservableObject {
    static let shared = RecordingState()

    @Published private(set) var status: RecordingStatus = .idle
    @Published private(set) var transcribedText: String = ""
    @Published private(set) var isModelLoaded: Bool = false

    private let realtimeSpeechService = RealtimeSpeechService.shared
    private let overlayManager = TranscriptionOverlayManager.shared

    private init() {
        Task {
            await loadModel()
        }
    }

    /// 加载 Whisper 模型
    func loadModel() async {
        do {
            try await realtimeSpeechService.loadModel()
            isModelLoaded = true
        } catch {
            status = .error("模型加载失败: \(error.localizedDescription)")
        }
    }

    /// 开始录音（长按触发）
    func startRecording() {
        guard status == .idle || status != .recording else { return }

        Task {
            await performStartRecording()
        }
    }

    /// 停止录音（释放触发）
    func stopRecording() {
        guard status == .recording else { return }

        Task {
            await performStopRecording()
        }
    }

    /// 切换录音状态（兼容单击模式）
    func toggleRecording() {
        Task {
            switch status {
            case .idle, .error:
                await performStartRecording()
            case .recording:
                await performStopRecording()
            case .transcribing:
                break
            }
        }
    }

    /// 执行开始录音
    private func performStartRecording() async {
        do {
            // 显示悬浮窗
            overlayManager.show()

            try await realtimeSpeechService.startRecording()
            status = .recording
        } catch {
            status = .error("录音启动失败: \(error.localizedDescription)")
            overlayManager.hide()
        }
    }

    /// 执行停止录音
    private func performStopRecording() async {
        status = .transcribing

        // 停止录音并获取最终转写结果
        let finalText = await realtimeSpeechService.stopRecording()
        transcribedText = finalText

        // 更新悬浮窗
        overlayManager.updateText(finalText)
        overlayManager.complete()

        // 粘贴到光标位置
        if !finalText.isEmpty {
            copyAndPaste(finalText)
        }

        status = .idle

        // 延迟关闭悬浮窗
        try? await Task.sleep(nanoseconds: 500_000_000)
        overlayManager.hide()
    }

    /// 复制并粘贴文本
    private func copyAndPaste(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.simulatePaste()
        }
    }

    /// 模拟粘贴
    private func simulatePaste() {
        let vKeyCode: CGKeyCode = 0x09
        guard let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: vKeyCode, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: vKeyCode, keyDown: false) else { return }

        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand

        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }
}
