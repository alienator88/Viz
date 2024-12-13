//
//  Notification.swift
//  Grabber
//
//  Created by Alin Lupascu on 4/5/24.
//

import Foundation
import AppKit
import SwiftUI

var previewWindow: NSWindow?
var cmdOutputWindow: NSWindow?

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
