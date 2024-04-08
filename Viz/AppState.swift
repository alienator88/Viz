//
//  AppState.swift
//  Grabber
//
//  Created by Alin Lupascu on 4/8/24.
//

import Foundation
import ServiceManagement

class AppState: ObservableObject {
    @Published var releases = [Release]()
    @Published var progressBar: (String, Double) = ("Ready", 0.0)
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


enum NewWindow:Int
{
    case update
    case no_update
}

