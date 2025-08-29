//
//  GrabberApp.swift
//  Grabber
//
//  Created by Alin Lupascu on 4/5/24.
//

import SwiftUI
import KeyboardShortcuts
import AlinFoundation

@main
struct VizApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var appState = AppState.shared
    @StateObject private var updater = Updater(owner: "alienator88", repo: "Viz")

    var body: some Scene {
        MenuBarExtra("Viz", systemImage: updater.updateAvailable ? "arrow.down.circle" : "eye", content: {
            ContentView()
                .environment(\.colorScheme, .dark)
                .preferredColorScheme(.dark)
                .environmentObject(updater)
                .environmentObject(appState)
                .environmentObject(HistoryState.shared)
        })
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsView()
                .environmentObject(appState)
                .environmentObject(HistoryState.shared)
                .environmentObject(updater)
                .toolbarBackground(.clear)
                .movableByWindowBackground()
        }
    }
}


class AppDelegate: NSObject, NSApplicationDelegate {
    @Environment(\.dismiss) private var dismiss
    @State private var windowController = WindowManager.shared

    func applicationDidFinishLaunching(_ notification: Notification) {

        KeyboardShortcuts.onKeyUp(for: .captureContent) {
            CaptureService.shared.captureContent()
        }

        KeyboardShortcuts.onKeyUp(for: .captureWebcam) {
            self.dismiss()
            openWebcamCapture()
        }

        KeyboardShortcuts.onKeyUp(for: .eyedropper) {
            processColor()
        }

        KeyboardShortcuts.onKeyUp(for: .history) {
            self.windowController.open(id: "history", with: HistoryView(), width: 500, height: 600, material: .sidebar)
            self.dismiss()
        }

        KeyboardShortcuts.onKeyUp(for: .clear) {
            clearClipboard()
        }

#if !DEBUG
        ensureApplicationSupportFolderExists()
#endif

    }

}


extension KeyboardShortcuts.Name {
    static let captureContent = Self("captureContent", default: .init(.one, modifiers: [.command, .control]))
}

extension KeyboardShortcuts.Name {
    static let captureWebcam = Self("captureWebcam", default: .init(.two, modifiers: [.command, .control]))
}

extension KeyboardShortcuts.Name {
    static let eyedropper = Self("eyedropper", default: .init(.three, modifiers: [.command, .control]))
}

extension KeyboardShortcuts.Name {
    static let history = Self("history", default: .init(.four, modifiers: [.command, .control]))
}

extension KeyboardShortcuts.Name {
    static let clear = Self("clear", default: .init(.five, modifiers: [.command, .control]))
}
