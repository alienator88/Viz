//
//  Notification.swift
//  Grabber
//
//  Created by Alin Lupascu on 4/5/24.
//

import Foundation
import AppKit
import SwiftUI
import AlinFoundation

var previewWindow: NSWindow?
var cmdOutputWindow: NSWindow?
var colorWindow: NSWindow?


struct PreviewContentView: View {
    let content: RecognizedContent

    var body: some View {
        VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
            .overlay(
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: "clipboard")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 14)
                        Text("Clipboard")
                            .font(.title2)
                        Spacer()

                        Button("Close") {
                            previewWindow?.orderOut(nil)
                            previewWindow = nil
                        }
                        .buttonStyle(SimpleButtonStyle(icon: "x.circle.fill", help: "Close", color: Color("mode"), size: 14))
                    }

                    Divider()

                    List(content.items) { item in
                        let text = item.text
                        let trimmedText = text.last == "\n" ? String(text.dropLast()) : text

                        Text(trimmedText)
                            .padding(4)
                            .listRowBackground(Color.clear)
                            .textSelection(.enabled)
                    }
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .listStyle(.plain)
                    .listRowBackground(Color.clear)
                    .padding(.top, 5)
                    .scrollIndicators(.visible)
                    .textSelection(.enabled)

                }
                .padding()
                .foregroundColor(Color("mode"))
            )


    }
}

func showPreviewWindow(content: RecognizedContent) {
    @AppStorage("previewSeconds") var seconds: Double = 5.0

    let hostingView = NSHostingView(rootView: PreviewContentView(content: content))
    hostingView.frame = CGRect(x: 0, y: 0, width: 300, height: 200)

    previewWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
                                  styleMask: .borderless,
                                  backing: .buffered,
                                  defer: false)
    previewWindow?.contentView = hostingView
    previewWindow?.contentView?.wantsLayer = true
    previewWindow?.contentView?.layer?.cornerRadius = 10
    previewWindow?.contentView?.layer?.masksToBounds = true
    previewWindow?.level = .floating
    previewWindow?.isOpaque = false
    previewWindow?.backgroundColor = .clear

    //    notificationWindow?.center()
    if let screen = NSScreen.main {
        let screenRect = screen.visibleFrame
        let windowX = screenRect.maxX - 300 - 30
        let windowY = screenRect.maxY - 200 - 30
        previewWindow?.setFrameOrigin(NSPoint(x: windowX, y: windowY))
    }

    previewWindow?.orderFront(nil)
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        previewWindow?.orderOut(nil)
        previewWindow = nil
    }

}



struct CmdOutputView: View {
    @AppStorage("cmdOutput") var cmdOutput: String = ""

    var body: some View {
        VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
            .overlay(
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: "terminal")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 14)
                        Text("Post-processing")
                            .font(.title2)
                        Spacer()

                        Button("Close") {
                            cmdOutputWindow?.orderOut(nil)
                            cmdOutputWindow = nil
                        }
                        .buttonStyle(SimpleButtonStyle(icon: "x.circle.fill", help: "Close", color: Color("mode"), size: 14))
                    }

                    Divider()

                    ScrollView {
                        Text(cmdOutput.isEmpty ? "No output to display" : cmdOutput)
                            .padding(4)
                            .textSelection(.enabled)
                    }

                }
                    .padding()
                    .foregroundColor(Color("mode"))
            )


    }
}

func showOutputWindow() {
    @AppStorage("previewSeconds") var seconds: Double = 5.0

    let hostingView = NSHostingView(rootView: CmdOutputView())
    hostingView.frame = CGRect(x: 0, y: 0, width: 300, height: 200)

    cmdOutputWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
                             styleMask: .borderless,
                             backing: .buffered,
                             defer: false)
    cmdOutputWindow?.contentView = hostingView
    cmdOutputWindow?.contentView?.wantsLayer = true
    cmdOutputWindow?.contentView?.layer?.cornerRadius = 10
    cmdOutputWindow?.contentView?.layer?.masksToBounds = true
    cmdOutputWindow?.level = .floating
    cmdOutputWindow?.isOpaque = false
    cmdOutputWindow?.backgroundColor = .clear

    //    notificationWindow?.center()
    if let screen = NSScreen.main {
        let screenRect = screen.visibleFrame
        let windowX = screenRect.maxX - 300 - 30
        let windowY = screenRect.maxY - 410 - 30
        cmdOutputWindow?.setFrameOrigin(NSPoint(x: windowX, y: windowY))
    }

    cmdOutputWindow?.orderFront(nil)
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        cmdOutputWindow?.orderOut(nil)
        cmdOutputWindow = nil
    }

}



func showColorPreviewWindowBackend() {
    @AppStorage("previewSeconds") var seconds: Double = 5.0

    let hostingView = NSHostingView(rootView: ColorPreviewView())
    hostingView.frame = CGRect(x: 0, y: 0, width: 300, height: 200)

    colorWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
                             styleMask: .borderless,
                             backing: .buffered,
                             defer: false)
    colorWindow?.contentView = hostingView
    colorWindow?.contentView?.wantsLayer = true
    colorWindow?.contentView?.layer?.cornerRadius = 10
    colorWindow?.contentView?.layer?.masksToBounds = true
    colorWindow?.level = .floating
    colorWindow?.isOpaque = false
    colorWindow?.backgroundColor = .clear

    //    notificationWindow?.center()
    if let screen = NSScreen.main {
        let screenRect = screen.visibleFrame
        let windowX = screenRect.maxX - 300 - 30
        let windowY = screenRect.maxY - 200 - 30
        colorWindow?.setFrameOrigin(NSPoint(x: windowX, y: windowY))
    }

    colorWindow?.orderFront(nil)
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        colorWindow?.orderOut(nil)
        colorWindow = nil
    }

}


struct ColorPreviewView: View {

    var body: some View {
        VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
            .overlay(
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: "clipboard")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 14)
                        Text("Clipboard")
                            .font(.title2)
                        Spacer()

                        Button("Close") {
                            colorWindow?.orderOut(nil)
                            colorWindow = nil
                        }
                        .buttonStyle(SimpleButtonStyle(icon: "x.circle.fill", help: "Close", color: Color("mode"), size: 14))
                    }

                    Divider()

                    if AppState.shared.colorSample.hexColor.isEmpty {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("No color selected")
                                .foregroundColor(.secondary)
                            Spacer()
                        }

                        Spacer()
                    } else {
                        Text("Hex: \(AppState.shared.colorSample.hexColor)")
                        Text("RGB: \(AppState.shared.colorSample.rgbColor)")
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppState.shared.colorSample.color)
                    }



                }
                    .padding()
                    .foregroundColor(Color("mode"))
            )


    }
}



struct HistoryView: View {
    @ObservedObject private var historyState = HistoryState.shared
    @State private var tappedItemID: String?

    var body: some View {

        VStack(alignment: .center, spacing: 0) {
            Text("History")
                .font(.title)

            Spacer()

            if historyState.historyItems.isEmpty {
                Text("Create a capture to display here")
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(historyState.historyItems) { item in
                            HStack(alignment: .center) {
                                Text(item.text)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                if tappedItemID == item.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.secondary.opacity(0.1))
                            }
                            .scaleEffect(tappedItemID == item.id ? 0.98 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: tappedItemID)
                            .onTapGesture {
                                tappedItemID = item.id
                                copyToClipboard(item.text)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    tappedItemID = nil
                                }
                            }
                        }
                    }
                }
                .scrollIndicators(.never)
//                .padding(.vertical)
            }

            Spacer()

            Text("Click item to copy")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.bottom)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)

    }
}




struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
