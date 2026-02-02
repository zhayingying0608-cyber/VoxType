import Foundation
import Carbon
import AppKit

/// 全局快捷键管理器（支持长按 Option 和双击 Shift）
final class GlobalShortcutManager {
    static let shared = GlobalShortcutManager()

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    // 长按 Option 相关
    private var isOptionPressed = false
    private var optionPressHandler: (() -> Void)?
    private var optionReleaseHandler: (() -> Void)?

    // 双击 Shift 相关
    private var lastShiftPressTime: Date?
    private var shiftClickCount = 0
    private var isRecordingFromShift = false
    private var shiftToggleHandler: (() -> Void)?

    private let doubleClickInterval: TimeInterval = 0.4 // 双击间隔

    private init() {}

    /// 设置长按 Option 的回调
    func setOptionHandlers(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) {
        optionPressHandler = onPress
        optionReleaseHandler = onRelease
    }

    /// 设置双击 Shift 的回调
    func setShiftDoubleClickHandler(_ handler: @escaping () -> Void) {
        shiftToggleHandler = handler
    }

    /// 开始监听
    func startListening() {
        let eventMask: CGEventMask = (1 << CGEventType.flagsChanged.rawValue)

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { proxy, type, event, refcon -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passRetained(event) }
                let manager = Unmanaged<GlobalShortcutManager>.fromOpaque(refcon).takeUnretainedValue()
                manager.handleFlagsChanged(event: event)
                return Unmanaged.passRetained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("无法创建事件监听，请在系统设置中授予辅助功能权限")
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    func stopListening() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
    }

    private func handleFlagsChanged(event: CGEvent) {
        let flags = event.flags
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

        // 检测 Option 键
        let optionDown = flags.contains(.maskAlternate)

        if optionDown && !isOptionPressed {
            // Option 按下
            isOptionPressed = true
            DispatchQueue.main.async {
                self.optionPressHandler?()
            }
        } else if !optionDown && isOptionPressed {
            // Option 释放
            isOptionPressed = false
            DispatchQueue.main.async {
                self.optionReleaseHandler?()
            }
        }

        // 检测 Shift 键双击
        // keyCode 56 = 左 Shift, 60 = 右 Shift
        let isShiftKey = keyCode == 56 || keyCode == 60
        let shiftDown = flags.contains(.maskShift)

        if isShiftKey && shiftDown {
            handleShiftPress()
        }
    }

    private func handleShiftPress() {
        let now = Date()

        if let lastPress = lastShiftPressTime {
            let interval = now.timeIntervalSince(lastPress)

            if interval < doubleClickInterval {
                // 双击检测成功
                shiftClickCount = 0
                lastShiftPressTime = nil

                DispatchQueue.main.async {
                    self.shiftToggleHandler?()
                }
                return
            }
        }

        // 记录这次按下
        lastShiftPressTime = now
        shiftClickCount = 1

        // 超时重置
        DispatchQueue.main.asyncAfter(deadline: .now() + doubleClickInterval) { [weak self] in
            if self?.shiftClickCount == 1 {
                self?.shiftClickCount = 0
                self?.lastShiftPressTime = nil
            }
        }
    }
}

// MARK: - 保留旧的结构用于设置页面显示
enum ShortcutName: String, CaseIterable {
    case holdOption = "holdOption"
    case doubleShift = "doubleShift"

    var displayName: String {
        switch self {
        case .holdOption: return "长按 Option"
        case .doubleShift: return "双击 Shift"
        }
    }

    var displayString: String {
        switch self {
        case .holdOption: return "⌥ 长按"
        case .doubleShift: return "⇧⇧ 双击"
        }
    }
}
