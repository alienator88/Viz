//
//  GrabberApp.swift
//  Grabber
//
//  Created by Alin Lupascu on 4/5/24.
//

import SwiftUI
import KeyboardShortcuts

@main
struct VizApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appState = AppState()

    var body: some Scene {
        MenuBarExtra("Viz", systemImage: "eye", content: {
            ContentView()
//                .environment(\.colorScheme, .dark)
                .preferredColorScheme(.dark)
                .onAppear {
#if !DEBUG
                    loadGithubReleases(appState: appState)
#endif
                }
        })
        .menuBarExtraStyle(.window)
        .commands {
            AboutCommand(appState: appState)
            CommandGroup(replacing: .newItem, addition: { })
        }
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
