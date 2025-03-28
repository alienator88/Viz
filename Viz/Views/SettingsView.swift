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
    @AppStorage("previewSeconds") var seconds: Double = 5.0
    @AppStorage("processing") var processingIsEnabled: Bool = false
    @AppStorage("postcommands") var postCommands: String = "say [ocr];"
    @AppStorage("mute") var mute: Bool = false
    @AppStorage("viewWidth") var viewWidth: Double = 300.0
    @AppStorage("viewHeight") var viewHeight: Double = 200.0
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .center) {
            GroupBox(label: Text("Settings").font(.title2)) {
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
                        .help("When enabled, captured content preview will show and close after \(seconds) seconds. Otherwise it's not shown at all.")

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

            GroupBox(label: Text("Keyboard Shortcuts").font(.title2)) {
                VStack(spacing: 10) {
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
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color("bg"))
        .environment(\.colorScheme, .dark)
        .preferredColorScheme(.dark)
    }
}
