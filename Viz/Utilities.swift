//
//  Utilities.swift
//  Grabber
//
//  Created by Alin Lupascu on 4/5/24.
//

import Foundation
import SwiftUI
import AppKit
import ServiceManagement


class TextItem: Identifiable {
    var id: String
    var text: String = ""

    init() {
        id = UUID().uuidString
    }
}


class RecognizedContent: ObservableObject {
    @Published var items = [TextItem]()
}



func copyTextItemsToClipboard(textItems: [TextItem]) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()

    let combinedText = textItems.map { $0.text }.joined(separator: "\n")
    pasteboard.setString(combinedText, forType: .string)
}

func copyColorsToClipboard(color: ColorSample) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
//    let textItems = [color.hexColor, color.rgbColor]
//    let combinedText = textItems.map { $0 }.joined(separator: "\n")
    pasteboard.setString(color.hexColor, forType: .string)
}


func clearClipboard() {
    DispatchQueue.main.async {
        CaptureService.shared.recognizedContent.items.removeAll()
        CaptureService.shared.pasteboard.clearContents()
        HistoryState.shared.historyItems.removeAll()
        previewWindow?.orderOut(nil)
        previewWindow = nil
    }
}


func pickColor() async -> ColorSample {
    await withCheckedContinuation { continuation in
        NSColorSampler().show { selectedColor in
            if let selectedColor = selectedColor,
               let color = selectedColor.usingColorSpace(.deviceRGB) {
                let red = Int(color.redComponent * 255)
                let green = Int(color.greenComponent * 255)
                let blue = Int(color.blueComponent * 255)
                let hex = String(format: "#%02X%02X%02X", red, green, blue)
                let rgb = "(\(red),\(green),\(blue))"
                let swiftUIColor = Color(nsColor: color)
                copyColorsToClipboard(color: ColorSample(hexColor: hex, rgbColor: rgb, color: swiftUIColor))
                continuation.resume(returning: ColorSample(hexColor: hex, rgbColor: rgb, color: swiftUIColor))
            } else {
                continuation.resume(returning: ColorSample(hexColor: "", rgbColor: "", color: .clear))
            }
        }
    }
}

func processColor() {
    Task {
        let result = await pickColor()
        AppState.shared.colorSample = result
        let textItemHex = TextItem()
        let textItemRGB = TextItem()
        textItemHex.text = result.hexColor
        textItemRGB.text = result.rgbColor
        HistoryState.shared.historyItems.append(textItemHex)
        HistoryState.shared.historyItems.append(textItemRGB)
        updateOnMain {
            showColorPreviewWindow()
        }
    }
}

func showColorPreviewWindow() {
    @AppStorage("processing") var processing: Bool = false
    @AppStorage("showPreview") var showPreview: Bool = true

    colorWindow?.orderOut(nil)
    colorWindow = nil
    if showPreview {
        showColorPreviewWindowBackend()
    }
}

extension NSColor {
    var hex: String {
        guard let rgbColor = usingColorSpace(.deviceRGB) else { return "N/A" }
        let red = Int(rgbColor.redComponent * 255)
        let green = Int(rgbColor.greenComponent * 255)
        let blue = Int(rgbColor.blueComponent * 255)
        return String(format: "#%02X%02X%02X", red, green, blue)
    }

    var rgb: String {
        guard let rgbColor = usingColorSpace(.deviceRGB) else { return "N/A" }
        let red = Int(rgbColor.redComponent * 255)
        let green = Int(rgbColor.greenComponent * 255)
        let blue = Int(rgbColor.blueComponent * 255)
        return "(\(red), \(green), \(blue))"
    }

    var swiftColor: Color {
        return Color(nsColor: self)
    }
}


func playSound() {
    if let sound = NSSound(named: "capture") {
        sound.play()
    }
}


class ScreenCaptureUtility {

    func captureScreenSelectionToClipboard(completion: @escaping (NSImage?) -> Void) {
        let process = Process()
        process.launchPath = "/usr/sbin/screencapture"
        process.arguments = ["-cix"]  // '-c' for clipboard, '-i' for interactive selection, '-x' for no capture sounds

        process.terminationHandler = { _ in
            DispatchQueue.main.async {
                let pasteboard = NSPasteboard.general
                if let image = pasteboard.readObjects(forClasses: [NSImage.self], options: [:])?.first as? NSImage {
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }

        process.launch()
    }
}



// Check app directory based on user permission
func checkAppDirectoryAndUserRole(completion: @escaping ((isInCorrectDirectory: Bool, isAdmin: Bool)) -> Void) {
    isCurrentUserAdmin { isAdmin in
        let bundlePath = Bundle.main.bundlePath as NSString
        let applicationsDir = "/Applications"
        let userApplicationsDir = "\(NSHomeDirectory())/Applications"

        var isInCorrectDirectory = false

        if isAdmin {
            // Admins can have the app in either /Applications or ~/Applications
            isInCorrectDirectory = bundlePath.deletingLastPathComponent == applicationsDir ||
            bundlePath.deletingLastPathComponent == userApplicationsDir
        } else {
            // Standard users should only have the app in ~/Applications
            isInCorrectDirectory = bundlePath.deletingLastPathComponent == userApplicationsDir
        }

        // Return both conditions: if the app is in the correct directory and if the user is an admin
        completion((isInCorrectDirectory, isAdmin))
    }
}


// Check if user is admin or standard user
func isCurrentUserAdmin(completion: @escaping (Bool) -> Void) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/zsh") // Using zsh, macOS default shell
    process.arguments = ["-c", "groups $(whoami) | grep -q ' admin '"]

    process.terminationHandler = { process in
        // On macOS, a process's exit status of 0 indicates success (admin group found in this context)
        completion(process.terminationStatus == 0)
    }

    do {
        try process.run()
    } catch {
        print("Failed to execute command: \(error)")
        completion(false)
    }
}

// Relaunch app
func relaunchApp(afterDelay seconds: TimeInterval = 0.5) -> Never {
    let task = Process()
    task.launchPath = "/bin/sh"
    task.arguments = ["-c", "sleep \(seconds); open \"\(Bundle.main.bundlePath)\""]
    task.launch()

    NSApp.terminate(nil)
    exit(0)
}



func updateLaunchAtLoginStatus(newValue: Bool) {
    do {
        if newValue {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            }
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    } catch {
        print("Failed to \(newValue ? "enable" : "disable") launch at login: \(error.localizedDescription)")
    }
}


func updateOnMain(after delay: Double? = nil, _ updates: @escaping () -> Void) {
    if let delay = delay {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            updates()
        }
    } else {
        DispatchQueue.main.async {
            updates()
        }
    }
}


extension Bundle {

    var name: String {
        func string(for key: String) -> String? {
            object(forInfoDictionaryKey: key) as? String
        }
        return string(for: "CFBundleDisplayName")
        ?? string(for: "CFBundleName")
        ?? "N/A"
    }
}

extension Bundle {

    var version: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }

    var buildVersion: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
    }
}

extension Bundle {

    var copyright: String {
        func string(for key: String) -> String? {
            object(forInfoDictionaryKey: key) as? String
        }
        return string(for: "NSHumanReadableCopyright") ?? "N/A"
    }
}



func replaceContentToken(in command: String, with content: String) -> String {
    return command.replacingOccurrences(of: "[ocr]", with: "\"\(content)\"")
}

func executeShellCommand(_ command: String) -> String {
    let process = Process()
    let pipe = Pipe()

    process.standardOutput = pipe
    process.standardError = pipe
    process.arguments = ["-c", command]
    process.launchPath = "/bin/zsh"
    process.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? "Error executing command"

    return output
}



