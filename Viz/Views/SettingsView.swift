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

struct SettingsView: View {
    @AppStorage("appendRecognizedText") var appendRecognizedText: Bool = false
    @AppStorage("keepLineBreaks") var keepLineBreaks: Bool = true
    @AppStorage("showPreview") var showPreview: Bool = true
    @AppStorage("processing") var processingIsEnabled: Bool = false
    @AppStorage("postcommands") var postCommands: String = ""
    @AppStorage("mute") var mute: Bool = false
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .center) {
            GroupBox(label: Text("Settings").font(.title2)) {
                VStack(alignment: .leading, spacing: 5) {

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
                        .help("When enabled, captured content preview will show and close after [X] seconds. Otherwise it's not shown at all.")

                    Toggle("Post-processing", isOn: $processingIsEnabled)
                        .toggleStyle(SpacedToggle())
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
                }
                .padding()
            }

            GroupBox(label: Text("Keyboard Shortcuts").font(.title2)) {
                VStack(spacing: 5) {
                    HStack {
                        Text("Text Capture")
                        Spacer()
                        KeyboardShortcuts.Recorder(for: .captureText)
                    }
                    HStack {
                        Text("Barcode Capture")
                        Spacer()
                        KeyboardShortcuts.Recorder(for: .captureBarcode)
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

            GroupBox(label: {
                HStack(alignment: .center, spacing: 5) {
                    Text("Post-Processing")
                    InfoButton(text: "Execute any shell commands after capture is completed. You may also use the [ocr] token in the commands. Example:\nsay [ocr]; echo [ocr] >> saved.txt")
                    Spacer()
                }
            }().font(.title2)) {
                HStack(alignment: .center, spacing: 10) {
                    TextEditor(text: $postCommands)
                        .frame(height: 50)
                        .focusable(false)
                        .font(.title3)
                        .overlay {
                            if postCommands.isEmpty {
                                VStack {
                                    HStack {
                                        Text("Example: say [ocr]; echo [ocr] >> file.txt").opacity(0.5)
                                        Spacer()
                                    }
                                    .padding(.leading, 8)
                                    .padding(.top, 2)
                                    Spacer()
                                }
                                .frame(height: 50)
                            }
                        }
                }
            }
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
