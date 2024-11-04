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
    @StateObject var appState = AppState()
    @StateObject private var updater = Updater(owner: "alienator88", repo: "Viz")

    var body: some Scene {
        MenuBarExtra("Viz", systemImage: "eye", content: {
            ContentView()
                .environment(\.colorScheme, .dark)
                .preferredColorScheme(.dark)
                .environmentObject(updater)
                .environmentObject(appState)
        })
        .menuBarExtraStyle(.window)
    }
}


class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {

        KeyboardShortcuts.onKeyUp(for: .captureText) {
            CaptureService.shared.captureText()
        }

        KeyboardShortcuts.onKeyUp(for: .captureBarcode) {
            CaptureService.shared.captureBarcodes()
        }

#if !DEBUG
        ensureApplicationSupportFolderExists()
#endif

    }

}


extension KeyboardShortcuts.Name {
    static let captureText = Self("captureText", default: .init(.one, modifiers: [.command, .shift]))
}

extension KeyboardShortcuts.Name {
    static let captureBarcode = Self("captureBarcode", default: .init(.two, modifiers: [.command, .option]))
}
