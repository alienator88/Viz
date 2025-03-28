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
    @AppStorage("processing") var processingIsEnabled: Bool = false
    @AppStorage("postcommands") var postCommands: String = ""
    @AppStorage("mute") var mute: Bool = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var updater: Updater
    @State private var windowController = WindowManager.shared


    var body: some View {

        VStack(alignment: .center) {

            HStack(alignment: .center, spacing: 10) {

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

                Button {
                    openAbout(updater: updater)
                    dismiss()
                } label: {
                    Image(systemName: updater.updateAvailable ? "arrow.down.circle" : "info.circle")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .foregroundStyle(updater.updateAvailable ? .green : .secondary)

                Button {
                    openSettings(appState: appState)
                    dismiss()
                } label: {
                    Image(systemName: "gear")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Button {
                    NSApp.terminate(nil)
                } label: {
                    Image(systemName: "x.circle")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }



            HStack(spacing: 5) {
                VStack {
                    Button("Text") {
                        CaptureService.shared.captureText()
                        dismiss()
                    }
                    .help("Capture section of screen to extract text from")
                    .buttonStyle(RoundedRectangleButtonStyle(image: "text.viewfinder", size: 15))

                    ShortcutEditorView(name: .captureText)

                }


                VStack(alignment: .center) {
                    Button("Barcode") {
                        CaptureService.shared.captureBarcodes()
                        dismiss()
                    }
                    .help("Capture QR Code or Barcode to extract text from")
                    .buttonStyle(RoundedRectangleButtonStyle(image: "qrcode.viewfinder", size: 15))

                    ShortcutEditorView(name: .captureBarcode)

                }


                VStack {
                    Button("Color") {
                        dismiss()
                        processColor()
                    }
                    .help("Capture hex/rgb value from click location")
                    .buttonStyle(RoundedRectangleButtonStyle(image: "eyedropper", size: 15))

                    ShortcutEditorView(name: .eyedropper)
                }

                VStack {
                    Button("History") {
                        openHistory()
                        dismiss()
                    }
                    .help("Show history of captures from this session")
                    .buttonStyle(RoundedRectangleButtonStyle(image: "clock", size: 15))

                    ShortcutEditorView(name: .history)

                }

                VStack {
                    Button("Clear") {
                        clearClipboard()
                    }
                    .help("Clear clipboard contents and stored captures")
                    .buttonStyle(RoundedRectangleButtonStyle(image: "delete.left", size: 15))

                    ShortcutEditorView(name: .clear)
                }

                //                Button {
                //                    openAbout(updater: updater)
                //                    dismiss()
                //                } label: {
                //                    Text(updater.updateAvailable ? "New Update" : "About")
                //                        .foregroundStyle(updater.updateAvailable ? .green : .primary)
                //                }
                //                .buttonStyle(RoundedRectangleButtonStyle(image: updater.updateAvailable ? "arrow.down.circle" : "info.circle", size: 15, color: updater.updateAvailable ? .green : .primary))
                //
                //                Button {
                //                    openSettings(appState: appState)
                //                    dismiss()
                //                } label: {
                //                    Text("Settings")
                //                }
                //                .buttonStyle(RoundedRectangleButtonStyle(image: "gear", size: 15))
                //
                //
                //                Button("Quit") {
                //                    NSApp.terminate(nil)
                //                }
                //                .buttonStyle(RoundedRectangleButtonStyle(image: "x.circle", size: 15))

            }


        }
        .padding()
        .background(Color("bg"))
        .frame(width: 600, height: 150)
    }
}
