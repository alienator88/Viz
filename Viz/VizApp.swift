//
//  GrabberApp.swift
//  Grabber
//
//  Created by Alin Lupascu on 4/5/24.
//

import SwiftUI
import Magnet


@main
struct VizApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appState = AppState()

    var body: some Scene {
        MenuBarExtra("Viz", systemImage: "eye", content: {
            ContentView()
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

        if let keyCombo = KeyCombo(key: .one, cocoaModifiers: [.command, .shift]) {
            let hotKey = HotKey(identifier: "CommandShift1", keyCombo: keyCombo) { hotKey in
                CaptureService.shared.captureText()
            }
            hotKey.register()
        }

        if let keyCombo = KeyCombo(key: .two, cocoaModifiers: [.command, .shift]) {
            let hotKey = HotKey(identifier: "CommandShift2", keyCombo: keyCombo) { hotKey in
                CaptureService.shared.captureBarcodes()
            }
            hotKey.register()
        }


#if !DEBUG
        ensureApplicationSupportFolderExists()
#endif

    }

}
