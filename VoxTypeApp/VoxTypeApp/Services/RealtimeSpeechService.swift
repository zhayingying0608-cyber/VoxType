import Foundation
import WhisperKit
import AVFoundation
import Combine

/// 实时语音转写服务
@MainActor
final class RealtimeSpeechService: ObservableObject {
    static let shared = RealtimeSpeechService()

    @Published private(set) var isModelLoaded = false
    @Published private(set) var currentText = ""
    @Published private(set) var isRecording = false

    private var whisperKit: WhisperKit?
    private var audioEngine: AVAudioEngine?
    private var audioBuffers: [Float] = []
    private var transcriptionTask: Task<Void, Never>?
    private let sampleRate: Double = 16000

    private init() {}

    /// 加载模型
    func loadModel() async throws {
        whisperKit = try await WhisperKit(
            model: "base",
            verbose: false,
            logLevel: .none
        )
        isModelLoaded = true
    }

    /// 开始录音和实时转写
    func startRecording() async throws {
        guard let whisper = whisperKit else {
            throw NSError(domain: "RealtimeSpeechService", code: 1, userInfo: [NSLocalizedDescriptionKey: "模型未加载"])
        }

        // 请求麦克风权限
        let granted = await requestMicrophonePermission()
        guard granted else {
            throw NSError(domain: "RealtimeSpeechService", code: 2, userInfo: [NSLocalizedDescriptionKey: "麦克风权限被拒绝"])
        }

        audioBuffers = []
        currentText = ""
        isRecording = true

        // 设置音频引擎
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }

        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)

        // 创建转换格式
        let recordingFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!

        // 创建格式转换器
        guard let converter = AVAudioConverter(from: inputFormat, to: recordingFormat) else {
            throw NSError(domain: "RealtimeSpeechService", code: 3, userInfo: [NSLocalizedDescriptionKey: "无法创建音频转换器"])
        }

        // 安装音频 tap
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { [weak self] buffer, _ in
            guard let self = self else { return }

            // 转换采样率
            let frameCount = AVAudioFrameCount(Double(buffer.frameLength) * self.sampleRate / inputFormat.sampleRate)
            guard let convertedBuffer = AVAudioPCMBuffer(pcmFormat: recordingFormat, frameCapacity: frameCount) else { return }

            var error: NSError?
            let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
                outStatus.pointee = .haveData
                return buffer
            }

            converter.convert(to: convertedBuffer, error: &error, withInputFrom: inputBlock)

            if error == nil {
                let floatArray = self.convertBufferToFloatArray(convertedBuffer)
                Task { @MainActor in
                    self.audioBuffers.append(contentsOf: floatArray)
                }
            }
        }

        try audioEngine.start()

        // 启动实时转写任务
        transcriptionTask = Task {
            await self.performRealtimeTranscription(whisper: whisper)
        }
    }

    /// 停止录音
    func stopRecording() async -> String {
        isRecording = false

        // 停止音频引擎
        if let engine = audioEngine {
            engine.inputNode.removeTap(onBus: 0)
            engine.stop()
        }
        audioEngine = nil

        // 取消实时转写任务
        transcriptionTask?.cancel()
        transcriptionTask = nil

        // 最终转写
        if let whisper = whisperKit, !audioBuffers.isEmpty {
            do {
                let results = try await whisper.transcribe(audioArray: audioBuffers)
                let finalText = results.map { $0.text }.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                currentText = finalText
                return finalText
            } catch {
                return currentText
            }
        }

        return currentText
    }

    /// 执行实时转写
    private func performRealtimeTranscription(whisper: WhisperKit) async {
        var lastTranscribedCount = 0
        let minSamplesForTranscription = Int(sampleRate * 0.8) // 至少 0.8 秒的音频

        while isRecording && !Task.isCancelled {
            // 每 0.8 秒尝试转写一次
            try? await Task.sleep(nanoseconds: 800_000_000)

            guard isRecording && !Task.isCancelled else { break }

            let currentBuffers = audioBuffers
            let newSamples = currentBuffers.count - lastTranscribedCount

            // 只有当有足够新音频时才转写
            guard newSamples >= minSamplesForTranscription else { continue }

            do {
                let results = try await whisper.transcribe(audioArray: currentBuffers)
                let text = results.map { $0.text }.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)

                guard isRecording else { break }

                self.currentText = text
                TranscriptionOverlayManager.shared.updateText(text)

                lastTranscribedCount = currentBuffers.count
            } catch {
                // 转写出错，继续尝试
            }
        }
    }

    /// 请求麦克风权限
    private func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    /// 转换音频 buffer 为 Float 数组
    private func convertBufferToFloatArray(_ buffer: AVAudioPCMBuffer) -> [Float] {
        guard let channelData = buffer.floatChannelData else { return [] }
        let frameLength = Int(buffer.frameLength)
        let channelDataPointer = channelData[0]
        return Array(UnsafeBufferPointer(start: channelDataPointer, count: frameLength))
    }
}
