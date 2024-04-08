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
    @AppStorage("appendRecognizedText") var appendRecognizedText: Bool = false
    @AppStorage("keepLineBreaks") var keepLineBreaks: Bool = true
    @AppStorage("closePreview") var closePreview: Bool = false


    var body: some Scene {
        MenuBarExtra("Viz", systemImage: "eye", content: {
            Button("Capture Text") {
                CaptureService.shared.captureText()
            }
            .help("Capture section of screen to extract text from")
            .keyboardShortcut("1", modifiers: [.command, .shift])


            Button("Capture QR/Barcode") {
                CaptureService.shared.captureBarcodes()
            }
            .help("Capture QR Code or Barcode to extract text from")
            .keyboardShortcut("2", modifiers: [.command, .shift])

            Divider()

            Button("Clear Clipboard") {
                clearClipboard()
            }
            .help("Clear clipboard contents and stored captures")


            // Settings Menu
            Menu("Settings") {
                Toggle("Append Content", isOn: $appendRecognizedText)
                    .help("When enabled, consecutive captures will be appended to the clipboard")
                Toggle("Line Breaks", isOn: $keepLineBreaks)
                    .help("When enabled, new lines will be added in scanned text")
                Toggle("Auto-Hide Preview", isOn: $closePreview)
                    .help("When enabled, copied content preview will close after 3 seconds")
                Toggle("Launch at Login", isOn: Binding(
                    get: { appState.isLaunchAtLoginEnabled },
                    set: { newValue in
                        updateOnMain {
                            appState.isLaunchAtLoginEnabled = newValue
                            updateLaunchAtLoginStatus(newValue: newValue)
                        }

                    }
                ))

            }



            Divider()

            Button {
                AboutWindow.show()
            } label: {
                Text("About \(Bundle.main.name)")
            }

            Button {
                loadGithubReleases(appState: appState, manual: true)
            } label: {
                Text("Check for Updates")
            }

            Button("Quit \(Bundle.main.name)") {
                NSApp.terminate(nil)
            }
        })
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
//        loadGithubReleases(appState: appState)
#endif

    }

}
