import Foundation
import Carbon
import AppKit

/// 快捷键名称
enum ShortcutName: String, CaseIterable {
    case toggleRecording = "toggleRecording"
    case pauseRecording = "pauseRecording"

    var displayName: String {
        switch self {
        case .toggleRecording: return "开始/停止录音"
        case .pauseRecording: return "暂停/继续录音"
        }
    }

    var defaultShortcut: GlobalShortcut {
        switch self {
        case .toggleRecording:
            return GlobalShortcut(keyCode: UInt32(kVK_Space), modifiers: UInt32(optionKey))
        case .pauseRecording:
            return GlobalShortcut(keyCode: UInt32(kVK_ANSI_P), modifiers: UInt32(optionKey))
        }
    }
}

/// 全局快捷键
struct GlobalShortcut: Codable, Equatable {
    let keyCode: UInt32
    let modifiers: UInt32

    var displayString: String {
        var parts: [String] = []
        if modifiers & UInt32(controlKey) != 0 { parts.append("⌃") }
        if modifiers & UInt32(optionKey) != 0 { parts.append("⌥") }
        if modifiers & UInt32(shiftKey) != 0 { parts.append("⇧") }
        if modifiers & UInt32(cmdKey) != 0 { parts.append("⌘") }
        parts.append(keyCodeToString(keyCode))
        return parts.joined(separator: "")
    }

    private func keyCodeToString(_ keyCode: UInt32) -> String {
        switch Int(keyCode) {
        case kVK_Space: return "Space"
        case kVK_Return: return "↩"
        case kVK_ANSI_A...kVK_ANSI_Z:
            let letters = "ASDFHGZXCVBQWERYTPOIULKJNM"
            let index = Int(keyCode)
            if index < letters.count {
                return String(letters[letters.index(letters.startIndex, offsetBy: index)])
            }
            return "?"
        default: return "?"
        }
    }
}

/// 全局快捷键管理器（支持长按）
final class GlobalShortcutManager {
    static let shared = GlobalShortcutManager()

    private var shortcuts: [ShortcutName: GlobalShortcut] = [:]
    private var keyDownHandlers: [ShortcutName: () -> Void] = [:]
    private var keyUpHandlers: [ShortcutName: () -> Void] = [:]

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var isKeyPressed: [ShortcutName: Bool] = [:]

    private init() {
        loadShortcuts()
        for name in ShortcutName.allCases {
            isKeyPressed[name] = false
        }
    }

    private func loadShortcuts() {
        for name in ShortcutName.allCases {
            if let data = UserDefaults.standard.data(forKey: "shortcut_\(name.rawValue)"),
               let shortcut = try? JSONDecoder().decode(GlobalShortcut.self, from: data) {
                shortcuts[name] = shortcut
            } else {
                shortcuts[name] = name.defaultShortcut
            }
        }
    }

    func saveShortcut(_ name: ShortcutName, shortcut: GlobalShortcut) {
        shortcuts[name] = shortcut
        if let data = try? JSONEncoder().encode(shortcut) {
            UserDefaults.standard.set(data, forKey: "shortcut_\(name.rawValue)")
        }
    }

    func getShortcut(_ name: ShortcutName) -> GlobalShortcut {
        shortcuts[name] ?? name.defaultShortcut
    }

    func setKeyDownHandler(for name: ShortcutName, handler: @escaping () -> Void) {
        keyDownHandlers[name] = handler
    }

    func setKeyUpHandler(for name: ShortcutName, handler: @escaping () -> Void) {
        keyUpHandlers[name] = handler
    }

    /// 开始监听
    func startListening() {
        let eventMask: CGEventMask = (1 << CGEventType.keyDown.rawValue) |
                                     (1 << CGEventType.keyUp.rawValue) |
                                     (1 << CGEventType.flagsChanged.rawValue)

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { proxy, type, event, refcon -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passRetained(event) }
                let manager = Unmanaged<GlobalShortcutManager>.fromOpaque(refcon).takeUnretainedValue()
                manager.handleEvent(type: type, event: event)
                return Unmanaged.passRetained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("无法创建事件监听，请检查辅助功能权限")
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

    private func handleEvent(type: CGEventType, event: CGEvent) {
        let keyCode = UInt32(event.getIntegerValueField(.keyboardEventKeycode))
        let flags = event.flags

        for name in ShortcutName.allCases {
            guard let shortcut = shortcuts[name] else { continue }

            let modifiersMatch = checkModifiers(flags, required: shortcut.modifiers)

            switch type {
            case .keyDown:
                if keyCode == shortcut.keyCode && modifiersMatch {
                    if isKeyPressed[name] == false {
                        isKeyPressed[name] = true
                        DispatchQueue.main.async {
                            self.keyDownHandlers[name]?()
                        }
                    }
                }

            case .keyUp:
                if keyCode == shortcut.keyCode {
                    if isKeyPressed[name] == true {
                        isKeyPressed[name] = false
                        DispatchQueue.main.async {
                            self.keyUpHandlers[name]?()
                        }
                    }
                }

            case .flagsChanged:
                // 当修饰键释放时也停止
                if isKeyPressed[name] == true && !modifiersMatch {
                    isKeyPressed[name] = false
                    DispatchQueue.main.async {
                        self.keyUpHandlers[name]?()
                    }
                }

            default:
                break
            }
        }
    }

    private func checkModifiers(_ flags: CGEventFlags, required: UInt32) -> Bool {
        var hasRequired = true

        if required & UInt32(optionKey) != 0 {
            hasRequired = hasRequired && flags.contains(.maskAlternate)
        }
        if required & UInt32(cmdKey) != 0 {
            hasRequired = hasRequired && flags.contains(.maskCommand)
        }
        if required & UInt32(controlKey) != 0 {
            hasRequired = hasRequired && flags.contains(.maskControl)
        }
        if required & UInt32(shiftKey) != 0 {
            hasRequired = hasRequired && flags.contains(.maskShift)
        }

        return hasRequired
    }
}
