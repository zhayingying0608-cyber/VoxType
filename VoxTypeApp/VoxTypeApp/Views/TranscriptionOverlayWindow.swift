import SwiftUI
import AppKit

/// 转写悬浮窗管理器
@MainActor
final class TranscriptionOverlayManager: ObservableObject {
    static let shared = TranscriptionOverlayManager()

    private var window: NSWindow?

    @Published var isVisible: Bool = false
    @Published var transcribedText: String = ""
    @Published var isTranscribing: Bool = false
    @Published var audioLevel: Float = 0

    private init() {}

    /// 显示悬浮窗
    func show() {
        if window == nil {
            createWindow()
        }

        transcribedText = ""
        isTranscribing = true
        isVisible = true
        window?.orderFront(nil)
        positionWindow()
    }

    /// 隐藏悬浮窗
    func hide() {
        isVisible = false
        isTranscribing = false
        window?.orderOut(nil)
    }

    /// 更新转写文本
    func updateText(_ text: String) {
        transcribedText = text
    }

    /// 更新音频电平
    func updateAudioLevel(_ level: Float) {
        audioLevel = level
    }

    /// 完成转写
    func complete() {
        isTranscribing = false
    }

    private func createWindow() {
        let contentView = TranscriptionOverlayView(manager: self)
        let hostingView = NSHostingView(rootView: contentView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 80),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.contentView = hostingView
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isMovableByWindowBackground = true
        window.hasShadow = true

        self.window = window
    }

    private func positionWindow() {
        guard let window = window, let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let windowFrame = window.frame
        let x = screenFrame.midX - windowFrame.width / 2
        let y = screenFrame.minY + 120
        window.setFrameOrigin(NSPoint(x: x, y: y))
    }
}

/// 转写悬浮窗视图
struct TranscriptionOverlayView: View {
    @ObservedObject var manager: TranscriptionOverlayManager
    @State private var pulseAnimation = false

    var body: some View {
        HStack(spacing: 14) {
            // 录音指示器
            ZStack {
                // 外圈脉冲动画
                Circle()
                    .stroke(Color.red.opacity(0.3), lineWidth: 2)
                    .frame(width: 36, height: 36)
                    .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                    .opacity(pulseAnimation ? 0 : 0.6)

                // 内圈
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.red, Color.red.opacity(0.8)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 14
                        )
                    )
                    .frame(width: 28, height: 28)
                    .shadow(color: .red.opacity(0.5), radius: 8, x: 0, y: 0)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false)) {
                    pulseAnimation = true
                }
            }

            // 文本区域
            VStack(alignment: .leading, spacing: 4) {
                // 转写文本
                Text(manager.transcribedText.isEmpty ? "正在聆听..." : manager.transcribedText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(manager.transcribedText.isEmpty ? .white.opacity(0.5) : .white)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // 底部提示
                HStack(spacing: 6) {
                    Image(systemName: "keyboard")
                        .font(.system(size: 9))
                    Text("松开完成")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(width: 420, height: 80)
        .background(
            ZStack {
                // 深色背景
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.85))

                // 边框高光
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.2), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: .black.opacity(0.4), radius: 30, x: 0, y: 15)
    }
}
