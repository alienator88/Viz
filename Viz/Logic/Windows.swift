//
//  Windows.swift
//  Viz
//
//  Created by Alin Lupascu on 3/27/25.
//

import SwiftUI
import AlinFoundation

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
