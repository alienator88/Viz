//
//  AppState.swift
//  Grabber
//
//  Created by Alin Lupascu on 4/8/24.
//

import Foundation
import ServiceManagement

class AppState: ObservableObject {
    @Published var isLaunchAtLoginEnabled: Bool = false

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
    @Published var historyItems: [TextItem] = []
}
