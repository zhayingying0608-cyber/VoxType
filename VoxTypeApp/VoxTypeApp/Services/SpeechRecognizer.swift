import Foundation
import WhisperKit

/// 语音识别错误
enum SpeechRecognizerError: LocalizedError {
    case modelNotLoaded
    case transcriptionFailed(String)

    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "Whisper 模型未加载"
        case .transcriptionFailed(let message):
            return "转写失败: \(message)"
        }
    }
}

/// 语音识别服务
final class SpeechRecognizer {
    private var whisperKit: WhisperKit?

    /// 加载 Whisper 模型
    func loadModel() async throws {
        whisperKit = try await WhisperKit(
            model: "base",
            verbose: false,
            logLevel: .none
        )
    }

    /// 转写音频文件
    func transcribe(audioURL: URL) async throws -> String {
        guard let whisper = whisperKit else {
            throw SpeechRecognizerError.modelNotLoaded
        }

        do {
            let results = try await whisper.transcribe(audioPath: audioURL.path)
            let text = results.map { $0.text }.joined(separator: " ")
            return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } catch {
            throw SpeechRecognizerError.transcriptionFailed(error.localizedDescription)
        }
    }

    /// 检查模型是否已加载
    var isModelLoaded: Bool {
        whisperKit != nil
    }
}
