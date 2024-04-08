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

struct PreviewContentView: View {
    let content: RecognizedContent
    var body: some View {
        VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
            .overlay(
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: "clipboard")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10)
                        Text("Copied!")
                            .font(.title2)
                        Spacer()

                        Button("Clear") {
                            clearClipboard()
                        }
                        .buttonStyle(SimpleButtonBrightStyle(icon: "eraser", help: "Clear", color: Color("mode")))

                        Button("Close") {
                            previewWindow?.orderOut(nil)
                            previewWindow = nil
                        }
                        .buttonStyle(SimpleButtonBrightStyle(icon: "x.circle.fill", help: "Close", color: Color("mode")))
                    }

                    Divider()

                    List(content.items) { item in
                        let text = item.text
                        let trimmedText = text.last == "\n" ? String(text.dropLast()) : text

                        Text(trimmedText)
                            .padding(4)
                            .listRowBackground(Color.clear)
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

func showPreview(content: RecognizedContent) {
    @AppStorage("closePreview") var closePreview: Bool = false

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
    if closePreview {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            previewWindow?.orderOut(nil)
            previewWindow = nil
        }
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
