//
//  AppState.swift
//  Grabber
//
//  Created by Alin Lupascu on 4/8/24.
//

import Foundation
import ServiceManagement
import SwiftUI
import AlinFoundation

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var isLaunchAtLoginEnabled: Bool = false
    @Published var colorSample: ColorItem = ColorItem(hex: "#FFFFFF", rgb: "(255,255,255)")

    init() {
        fetchLaunchAtLoginStatus()
    }

    func fetchLaunchAtLoginStatus() {
        // Fetch the actual launch at login status asynchronously
        DispatchQueue.global(qos: .background).async {
            let launchStatus = SMAppService.mainApp.status == .enabled
            DispatchQueue.main.async {
                self.isLaunchAtLoginEnabled = launchStatus
            }
        }
    }

}

class HistoryState: ObservableObject {
    static let shared = HistoryState()
    @Published var historyItems: [HistoryEntry] = [] {
        didSet {
            saveToDisk()
        }
    }

    private let fileName = "historyItems.json"

    init() {
        loadFromDisk()
    }

    private func getFileURL() -> URL? {
        let fileManager = FileManager.default
        guard let supportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent(Bundle.main.name) else {
            printOS("Failed to construct Application Support path.")
            return nil
        }
        return supportURL.appendingPathComponent(fileName)
    }

    private func loadFromDisk() {
        guard let url = getFileURL(),
              FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data)
        else { return }

        self.historyItems = decoded
    }

    private func saveToDisk() {
        guard let url = getFileURL() else { return }
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        if let data = try? JSONEncoder().encode(historyItems) {
            try? data.write(to: url)
        }
    }
}

enum HistoryEntry: Identifiable, Codable {
    case text(TextItem)
    case color(ColorItem)

    var id: String {
        switch self {
        case .text(let item): return item.id
        case .color(let item): return item.id
        }
    }
}

class TextItem: Identifiable, Codable {
    let id: String
    var text: String

    init(text: String) {
        self.id = UUID().uuidString
        self.text = text
    }
}

struct ColorItem: Identifiable, Codable {
    let id: String
    let hex: String
    let rgb: String
    var color: Color { Color(hex: hex) ?? Color.white }

    init(hex: String, rgb: String) {
        self.id = UUID().uuidString
        self.hex = hex
        self.rgb = rgb
    }
}
