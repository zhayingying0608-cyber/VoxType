import Foundation
import AVFoundation

/// 音频录制错误
enum AudioRecorderError: LocalizedError {
    case permissionDenied
    case recordingFailed(String)
    case noRecordingInProgress

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "麦克风权限被拒绝"
        case .recordingFailed(let message):
            return "录音失败: \(message)"
        case .noRecordingInProgress:
            return "没有正在进行的录音"
        }
    }
}

/// 音频录制服务
final class AudioRecorder: NSObject {
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?

    /// 请求麦克风权限
    private func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    /// 开始录音
    func startRecording() async throws {
        // 检查权限
        let granted = await requestPermission()
        guard granted else {
            throw AudioRecorderError.permissionDenied
        }

        // 创建临时文件路径
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "voxtype_recording_\(Date().timeIntervalSince1970).wav"
        let fileURL = tempDir.appendingPathComponent(fileName)
        recordingURL = fileURL

        // 配置录音设置
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
        } catch {
            throw AudioRecorderError.recordingFailed(error.localizedDescription)
        }
    }

    /// 停止录音并返回音频文件 URL
    func stopRecording() async throws -> URL {
        guard let recorder = audioRecorder, let url = recordingURL else {
            throw AudioRecorderError.noRecordingInProgress
        }

        recorder.stop()
        audioRecorder = nil

        return url
    }

    /// 检查是否正在录音
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
}
