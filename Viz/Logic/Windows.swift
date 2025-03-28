//
//  Windows.swift
//  Viz
//
//  Created by Alin Lupascu on 3/27/25.
//

import SwiftUI
import AlinFoundation

func openHistory() {
    WindowManager.shared.open(id: "history", with: HistoryView(), width: 500, height: 600, material: .sidebar)
}

func openAbout(updater: Updater) {
    WindowManager.shared.open(id: "about", with: AboutView().environmentObject(updater), width: 400, height: 450, material: .sidebar)
}

func openSettings(appState: AppState) {
    WindowManager.shared.open(id: "settings", with: SettingsView().environmentObject(appState), width: 500, height: 630)
}
