//
//  MainView.swift
//  Viz
//
//  Created by Alin Lupascu on 4/9/24.
//

import Foundation
import SwiftUI
import KeyboardShortcuts

struct ContentView: View {
    @StateObject var appState = AppState()
    @AppStorage("appendRecognizedText") var appendRecognizedText: Bool = false
    @AppStorage("keepLineBreaks") var keepLineBreaks: Bool = true
    @AppStorage("closePreview") var closePreview: Bool = false
    @AppStorage("processing") var processing: Bool = false
    @AppStorage("postcommands") var postCommands: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
            .overlay{
                VStack(alignment: .center, spacing: 15) {

                    Spacer()

                    HStack(spacing: 0) {

                        Spacer()

                        Text("V I Z")
                            .font(.system(size: 18, design: .rounded))
                            .bold()
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.red, .purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .black, radius: 2, x: 0, y: 0)

                        Spacer()
                    }



                    HStack(spacing: 15) {
                        VStack {
                            Button("Text") {
                                CaptureService.shared.captureText()
                                dismiss()
                            }
                            .help("Capture section of screen to extract text from")
                            .keyboardShortcut("1", modifiers: [.command, .shift])
                            .buttonStyle(RoundedRectangleButtonStyle(image: "text.viewfinder", size: 30))

                            KeyboardShortcuts.Recorder(for: .captureText)
                        }


                        VStack(alignment: .center) {
                            Button("QR/Barcode") {
                                CaptureService.shared.captureBarcodes()
                                dismiss()
                            }
                            .help("Capture QR Code or Barcode to extract text from")
                            .keyboardShortcut("2", modifiers: [.command, .shift])
                            .buttonStyle(RoundedRectangleButtonStyle(image: "qrcode.viewfinder", size: 30))

                            KeyboardShortcuts.Recorder(for: .captureBarcode)
                        }

                    }


                    Button("Clear Clipboard") {
                        clearClipboard()
                        dismiss()
                    }
                    .help("Clear clipboard contents and stored captures")
                    .buttonStyle(RoundedRectangleButtonStyle(image: "delete.left", size: 30))

                    if processing {
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
                            .padding(6)
                            .padding(.vertical, 4)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }



                    GroupBox(label: Text("Settings").font(.title2)) {
                        VStack(alignment: .leading, spacing: 10) {
                            Toggle("Append consecutive captures", isOn: $appendRecognizedText)
                                .toggleStyle(SpacedToggle())
                                .help("When enabled, consecutive captures will be appended to the clipboard")
                            Toggle("Keep line breaks in captures", isOn: $keepLineBreaks)
                                .toggleStyle(SpacedToggle())
                                .help("When enabled, new lines will be added in scanned text")
                            Toggle("Auto-hide capture window (3s)", isOn: $closePreview)
                                .toggleStyle(SpacedToggle())
                                .help("When enabled, captured content preview will close after 3 seconds")
                            Toggle("Post-processing", isOn: $processing)
                                .toggleStyle(SpacedToggle())
                                .help("When enabled, you can execute shell functions after capture")
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
                        .padding(6)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)


                    HStack() {

                        Button {
                            AboutWindow.show()
                            dismiss()
                        } label: {
                            Text("About")
                        }
                        .buttonStyle(RoundedRectangleButtonStyle(image: "info.circle", size: 15))

                        Button {
                            loadGithubReleases(appState: appState, manual: true)
                            dismiss()
                        } label: {
                            Text("Update")
                        }
                        .buttonStyle(RoundedRectangleButtonStyle(image: "arrow.down.circle", size: 15))


                        Button("Quit") {
                            NSApp.terminate(nil)
                        }
                        .buttonStyle(RoundedRectangleButtonStyle(image: "x.circle", size: 15))

                    }

                    Spacer()

                }
                .padding()
                .background(Color("bg"))

            }
            .frame(width: 330, height: processing ? 710 : 590)
    }
}
