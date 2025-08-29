//
//  Windows.swift
//  Viz
//
//  Created by Alin Lupascu on 3/27/25.
//

import SwiftUI
import AlinFoundation
import AVFoundation

func openHistory() {
    WindowManager.shared.open(id: "history", with: HistoryView(), width: 500, height: 600)
}

func openAbout() {
    WindowManager.shared.open(id: "about", with: AboutView(), width: 400, height: 450)
}

func openAppSettings(selectedTab: Int = 0) {
    if #available(macOS 14.0, *) {
        // For macOS 14+, we need to use a different approach since we can't directly control tab selection with openSettings
        // We'll store the selected tab and let SettingsView read it
        UserDefaults.standard.set(selectedTab, forKey: "settingsSelectedTab")
        @Environment(\.openSettings) var openSettings
        openSettings()
    } else {
        UserDefaults.standard.set(selectedTab, forKey: "settingsSelectedTab")
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}

private var webcamWindow: NSWindow?

func openWebcamCapture() {
    // Show existing window if already open
    if let existingWindow = webcamWindow, existingWindow.isVisible {
        DispatchQueue.main.async {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
        return
    }
    
    // Close existing window
    webcamWindow?.close()
    webcamWindow = nil
    
    // Create window on main thread (SwiftUI requirement)
    DispatchQueue.main.async {
        let hostingController = NSHostingController(rootView: WebcamCaptureView())
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 650, height: 450))
        window.styleMask = [.titled, .closable, .resizable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.level = .normal
        window.isReleasedWhenClosed = false
        window.center()
        window.minSize = NSSize(width: 320, height: 240)
        
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        webcamWindow = window
    }
}
