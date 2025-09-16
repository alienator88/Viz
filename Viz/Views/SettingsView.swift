//
//  SettingsView.swift
//  Viz
//
//  Created by Alin Lupascu on 3/27/25.
//

import Foundation
import SwiftUI
import AlinFoundation
import KeyboardShortcuts
import AVFoundation

struct SettingsView: View {
    @EnvironmentObject var updater: Updater
    @AppStorage("appendRecognizedText") var appendRecognizedText: Bool = false
    @AppStorage("keepLineBreaks") var keepLineBreaks: Bool = true
    @AppStorage("showPreview") var showPreview: Bool = true
    @AppStorage("previewSeconds") var seconds: Double = 5.0
    @AppStorage("processing") var processingIsEnabled: Bool = false
    @AppStorage("postcommands") var postCommands: String = "say [ocr];"
    @AppStorage("mute") var mute: Bool = false
    @AppStorage("viewWidth") var viewWidth: Double = 300.0
    @AppStorage("viewHeight") var viewHeight: Double = 200.0
    @EnvironmentObject var appState: AppState
    @AppStorage("settingsSelectedTab") private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView(
                appendRecognizedText: $appendRecognizedText,
                keepLineBreaks: $keepLineBreaks,
                showPreview: $showPreview,
                seconds: $seconds,
                processingIsEnabled: $processingIsEnabled,
                postCommands: $postCommands,
                mute: $mute,
                viewWidth: $viewWidth,
                viewHeight: $viewHeight
            )
            .tabItem {
                Image(systemName: "gear")
                Text("General")
            }
            .tag(0)
            
            ShortcutsSettingsView()
            .tabItem {
                Image(systemName: "keyboard")
                Text("Shortcuts")
            }
            .tag(1)
            
            UpdaterSettingsView()
                .environmentObject(updater)
            .tabItem {
                Image(systemName: "arrow.down.circle")
                Text("Updates")
            }
            .tag(2)

            AboutView()
                .tabItem {
                    Image(systemName: "info.circle")
                    Text("About")
                }
                .tag(3)
        }
        .frame(maxWidth: 500, maxHeight: .infinity)
        .background(Color("bg"))
        .environment(\.colorScheme, .dark)
        .preferredColorScheme(.dark)
    }
}

struct GeneralSettingsView: View {
    @Binding var appendRecognizedText: Bool
    @Binding var keepLineBreaks: Bool
    @Binding var showPreview: Bool
    @Binding var seconds: Double
    @Binding var processingIsEnabled: Bool
    @Binding var postCommands: String
    @Binding var mute: Bool
    @Binding var viewWidth: Double
    @Binding var viewHeight: Double
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .center) {
            GroupBox {
                VStack(alignment: .leading, spacing: 10) {

                    HStack {
                        Text("OCR Language")
                        Spacer()
                        LanguagePickerView()
                            .frame(width: 200)
                    }
                    HStack {
                        Text("OCR Quality")
                        Spacer()
                        QualityPickerView()
                            .frame(width: 200)
                    }

                    Toggle("Append consecutive captures", isOn: $appendRecognizedText)
                        .toggleStyle(SpacedToggle())
                        .help("When enabled, consecutive captures will be added on to the previous capture")

                    Toggle("Keep line breaks in captures", isOn: $keepLineBreaks)
                        .toggleStyle(SpacedToggle())
                        .help("New lines will be kept from scanned text")

                    Toggle("Show capture window for", isOn: $showPreview)
                        .toggleStyle(SpacedToggleSeconds())
                        .help("When enabled, captured content preview will show and close after \(Int(seconds)) seconds. Otherwise it's not shown at all.")

                    Toggle("Post-processing", isOn: $processingIsEnabled)
                        .toggleStyle(SpacedProcessingToggle())
                        .help("When enabled, you can execute shell functions after capture")

                    Toggle("Mute capture sound", isOn: $mute)
                        .toggleStyle(SpacedToggle())
                        .help("Mute the screen capture notification sound")

                    Toggle("Launch at login", isOn: Binding(
                        get: { appState.isLaunchAtLoginEnabled },
                        set: { newValue in
                            updateOnMain {
                                appState.isLaunchAtLoginEnabled = newValue
                                updateLaunchAtLoginStatus(newValue: newValue)
                            }
                        }
                    ))
                    .toggleStyle(SpacedToggle())

                    HStack {
                        Text("Capture Window Dimensions")
                            .help("The size of the window that shows the captured content at the top right of the screen")
                        Spacer()
                        HStack() {
                            Text("W:")
                            Stepper("\(Int(viewWidth))", value: $viewWidth, in: 200...1000, step: 10)
                                .frame(width: 60, alignment: .trailing)
                            Text("H:")
                            Stepper("\(Int(viewHeight))", value: $viewHeight, in: 100...1000, step: 10)
                                .frame(width: 60, alignment: .trailing)
                        }

                        Button {
                            viewWidth = 300.0
                            viewHeight = 200.0
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 12))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                        .help("Reset dimensions to default")

                        Button {
                            showPreviewWindow(contentView: PreviewContentView())
                        } label: {
                            Image(systemName: "macwindow")
                                .font(.system(size: 12))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                        .help("Show example window")
                    }
                }
                .padding()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct ShortcutsSettingsView: View {
    var body: some View {
        VStack(alignment: .center) {
            GroupBox {
                VStack(spacing: 10) {
                    HStack {
                        Text("Capture Content")
                        Spacer()
                        KeyboardShortcuts.Recorder(for: .captureContent)
                    }
                    HStack {
                        Text("Capture Webcam")
                        Spacer()
                        KeyboardShortcuts.Recorder(for: .captureWebcam)
                    }
                    HStack {
                        Text("Color Picker")
                        Spacer()
                        KeyboardShortcuts.Recorder(for: .eyedropper)
                    }
                    HStack {
                        Text("History Window")
                        Spacer()
                        KeyboardShortcuts.Recorder(for: .history)
                    }
                    HStack {
                        Text("Clear Clipboard")
                        Spacer()
                        KeyboardShortcuts.Recorder(for: .clear)
                    }
                }
                .padding()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}



struct UpdaterSettingsView: View {
    @EnvironmentObject private var updater: Updater

    var body: some View {
        VStack(alignment: .center) {
            GroupBox {
                VStack(alignment: .leading, spacing: 10) {

                    HStack {
                        FrequencyView(updater: updater)
                        if updater.updateAvailable {
                            Divider()
                                .padding(.trailing, 8)
                            UpdateBadge(updater: updater, hideLabel: true)
                        }

                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.primary.opacity(0.05))
                    }

                    RecentReleasesView(updater: updater)
                        .frame(height: 380)
                        .frame(maxWidth: .infinity)

                    // === Buttons ==============================================================================================

                    HStack(alignment: .center, spacing: 20) {
                        Spacer()
                        Button {
                            updater.checkForUpdates(sheet: true, force: true)
                        } label: {
                            Label("Refresh", systemImage: "arrow.uturn.left.circle")
                        }

                        Button {
                            NSWorkspace.shared.open(URL(string: "https://github.com/alienator88/Viz/releases")!)
                        } label: {
                            Label("Releases", systemImage: "link")
                        }
                        Spacer()
                    }
                }
                .padding()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
