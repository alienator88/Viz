//
//  MainView.swift
//  Viz
//
//  Created by Alin Lupascu on 4/9/24.
//

import Foundation
import SwiftUI
import KeyboardShortcuts
import AlinFoundation

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var historyState: HistoryState
    @AppStorage("appendRecognizedText") var appendRecognizedText: Bool = false
    @AppStorage("keepLineBreaks") var keepLineBreaks: Bool = true
    @AppStorage("showPreview") var showPreview: Bool = true
    @AppStorage("processing") var processing: Bool = false
    @AppStorage("postcommands") var postCommands: String = ""
    @AppStorage("mute") var mute: Bool = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var updater: Updater
    @State private var windowController = WindowManager()


    var body: some View {

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



            HStack(spacing: 5) {
                VStack {
                    Button("Text") {
                        CaptureService.shared.captureText()
                        dismiss()
                    }
                    .help("Capture section of screen to extract text from")
                    .buttonStyle(RoundedRectangleButtonStyle(image: "text.viewfinder", size: 15))

                    KeyboardShortcuts.Recorder(for: .captureText)
                }


                VStack(alignment: .center) {
                    Button("Barcode") {
                        CaptureService.shared.captureBarcodes()
                        dismiss()
                    }
                    .help("Capture QR Code or Barcode to extract text from")
                    .buttonStyle(RoundedRectangleButtonStyle(image: "qrcode.viewfinder", size: 15))

                    KeyboardShortcuts.Recorder(for: .captureBarcode)
                }


                VStack {
                    Button("Color") {
                        dismiss()
                        processColor()
                    }
                    .help("Capture hex/rgb value from click location")
                    .buttonStyle(RoundedRectangleButtonStyle(image: "eyedropper", size: 15))

                    KeyboardShortcuts.Recorder(for: .eyedropper)
                }

            }

            HStack(spacing: 15) {
                Button("History") {
                    windowController.open(with: HistoryView(), width: 500, height: 600)
                    dismiss()
                }
                .help("Show history of captures from this session")
                .buttonStyle(RoundedRectangleButtonStyle(image: "clock", size: 30))

                Button("Clear Captures") {
                    clearClipboard()
                }
                .help("Clear clipboard contents and stored captures")
                .buttonStyle(RoundedRectangleButtonStyle(image: "delete.left", size: 30))
            }




            GroupBox(label: Text("Settings").font(.title2)) {
                VStack(alignment: .leading, spacing: 10) {
                    Toggle("Append consecutive captures", isOn: $appendRecognizedText)
                        .toggleStyle(SpacedToggle())
                        .help("When enabled, consecutive captures will be appended to the clipboard")

                    Toggle("Keep line breaks in captures", isOn: $keepLineBreaks)
                        .toggleStyle(SpacedToggle())
                        .help("When enabled, new lines will be added in scanned text")

                    Toggle("Show capture window for", isOn: $showPreview)
                        .toggleStyle(SpacedToggleSeconds())
                        .help("When enabled, captured content preview will show and close after [X] seconds. Otherwise it's not shown at all.")

                    Toggle("Post-processing", isOn: $processing)
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
                .padding(6)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .leading)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

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


            HStack() {

                Button {
                    AboutWindow.show(updater: updater)
                    dismiss()
                } label: {
                    Text(updater.updateAvailable ? "New Update" : "About")
                        .foregroundStyle(updater.updateAvailable ? .green : .primary)
                }
                .buttonStyle(RoundedRectangleButtonStyle(image: updater.updateAvailable ? "arrow.down.circle" : "info.circle", size: 15, color: updater.updateAvailable ? .green : .primary))


                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .buttonStyle(RoundedRectangleButtonStyle(image: "x.circle", size: 15))

            }

            Spacer()

        }
        .padding()
        .background(Color("bg"))
        .frame(width: 450, height: processing ? 740 : 620)
    }
}
