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

    private func getFileURLs() -> (icloud: URL?, local: URL?) {
        let fileManager = FileManager.default
        let localSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent(Bundle.main.name)
        let localURL = localSupportURL?.appendingPathComponent(fileName)

        let icloudDir = fileManager.url(forUbiquityContainerIdentifier: "iCloud.com.alienator88.Viz")?.appendingPathComponent("Documents")
        let icloudURL = icloudDir?.appendingPathComponent(fileName)

        return (icloudURL, localURL)
    }

    private func loadFromDisk() {
        let urls = getFileURLs()
        let fileManager = FileManager.default

        if let icloud = urls.icloud, fileManager.fileExists(atPath: icloud.path),
           let data = try? Data(contentsOf: icloud),
           let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data) {
            self.historyItems = decoded
            return
        }

        if let local = urls.local, fileManager.fileExists(atPath: local.path),
           let data = try? Data(contentsOf: local),
           let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data) {
            self.historyItems = decoded

            // Copy to iCloud if not already there
            if let icloud = urls.icloud, !fileManager.fileExists(atPath: icloud.path) {
                do {
                    try fileManager.createDirectory(at: icloud.deletingLastPathComponent(), withIntermediateDirectories: true)
                    try data.write(to: icloud)
                } catch {
                    printOS("Failed to copy local history to iCloud: \(error)")
                }
            }
        }
    }

    private func saveToDisk() {
        let urls = getFileURLs()
        let fileManager = FileManager.default

        if let data = try? JSONEncoder().encode(historyItems) {
            if let icloud = urls.icloud {
                do {
                    try fileManager.createDirectory(at: icloud.deletingLastPathComponent(), withIntermediateDirectories: true)
                    try data.write(to: icloud)
                } catch {
                    printOS("Failed to save history to iCloud: \(error)")
                }
            }

            if let local = urls.local {
                do {
                    try fileManager.createDirectory(at: local.deletingLastPathComponent(), withIntermediateDirectories: true)
                    try data.write(to: local)
                } catch {
                    printOS("Failed to save history to local file: \(error)")
                }
            }
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
