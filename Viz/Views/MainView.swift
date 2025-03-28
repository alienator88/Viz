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
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var updater: Updater
    @State private var windowController = WindowManager.shared


    var body: some View {

        VStack(alignment: .center, spacing: 0) {

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
                    .padding(.leading, 5)


                Spacer()

                HStack() {
                    Button {
                        openAbout(updater: updater)
                        dismiss()
                    } label: {
                        Image(systemName: updater.updateAvailable ? "arrow.down.circle" : "info.circle")
                            .font(.system(size: 18))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(updater.updateAvailable ? .green : .secondary)

                    Button {
                        openSettings(appState: appState)
                        dismiss()
                    } label: {
                        Image(systemName: "gear")
                            .font(.system(size: 17))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)

                    Button {
                        NSApp.terminate(nil)
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .font(.system(size: 18))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                }
                .padding(4)
                .padding(.horizontal, 2)
                .background {
                    Capsule()
                        .fill(Color.secondary.opacity(0.2))
                }
            }
            .padding(6)


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

            }
            .padding([.horizontal, .bottom, .top])


        }
        .background(Color("bg"))
        .frame(width: 600)
    }
}
