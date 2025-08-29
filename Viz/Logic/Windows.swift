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

func openAbout(updater: Updater) {
    WindowManager.shared.open(id: "about", with: AboutView().environmentObject(updater), width: 400, height: 450)
}

func openAppSettings() {
    if #available(macOS 14.0, *) {
        @Environment(\.openSettings) var openSettings
        openSettings()
    } else {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}

private var webcamWindow: NSWindow?

func openWebcamCapture() {
    // Show existing window if already open
    if let existingWindow = webcamWindow, existingWindow.isVisible {
        existingWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        return
    }
    
    // Close and nil out existing window
    webcamWindow?.close()
    webcamWindow = nil
    
    // Create custom resizable window
    let hostingController = NSHostingController(rootView: WebcamCaptureView())
    let window = NSWindow(contentViewController: hostingController)
    window.setContentSize(NSSize(width: 750, height: 550))
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
