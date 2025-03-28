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
    @ObservedObject var appState = AppState.shared
    @ObservedObject var content = RecognizedContent.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()

                Button("Close") {
                    previewWindow?.orderOut(nil)
                    previewWindow = nil
                }
                .buttonStyle(SimpleButtonStyle(icon: "x.circle.fill", help: "Close", color: .primary, size: 14))
            }
            .padding(2)

            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(content.items, id: \.id) { item in
                        let text = item.text
                        let trimmedText = text.last == "\n" ? String(text.dropLast()) : text
                        Text(trimmedText)
                            .textSelection(.enabled)
                    }
                }
            }
            .scrollIndicators(.visible)
            .padding([.horizontal, .bottom])
            .frame(minWidth: 200)

            Spacer()


            if !appState.cmdOutput.isEmpty {
                HStack(spacing: 0) {
                    Rectangle()
                        .frame(height: 1)
                        .opacity(0.2)

                    Text("Processing Output")
                        .textCase(.uppercase)
                        .font(.footnote)
                        .opacity(0.6)
                        .padding(.horizontal, 10)
                        .frame(minWidth: 150)

                    Rectangle()
                        .frame(height: 1)
                        .opacity(0.2)
                }
                .frame(minHeight: 35)

                ScrollView {
                    Text(appState.cmdOutput)
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(width: .infinity, alignment: .leading)
                }
                .scrollIndicators(.visible)
                .padding([.horizontal, .bottom])


            }
        }
        .foregroundColor(.primary)
        .material(.sidebar)
    }
}


struct ColorPreviewView: View {

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()

                Button("Close") {
                    previewWindow?.orderOut(nil)
                    previewWindow = nil
                }
                .buttonStyle(SimpleButtonStyle(icon: "x.circle.fill", help: "Close", color: .primary, size: 14))
            }
            .padding(2)

            VStack(alignment: .leading) {
                Text("Hex: \(AppState.shared.colorSample.hex)")
                Text("RGB: \(AppState.shared.colorSample.rgb)")
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppState.shared.colorSample.color)
            }
            .padding([.horizontal, .bottom])
        }
        .foregroundColor(.primary)
        .material(.sidebar)
    }
}





func showPreviewWindow<Content: View>(contentView: Content) {
    @AppStorage("previewSeconds") var seconds: Double = 5.0
    @AppStorage("processing") var processingIsEnabled: Bool = false
    @AppStorage("showPreview") var showPreview: Bool = true

    guard showPreview else { return }

    previewWindow?.orderOut(nil)
    previewWindow = nil

    let height: CGFloat = (processingIsEnabled && contentView is PreviewContentView) ? 300 : 200
    let hostingView = NSHostingView(rootView: contentView)
    hostingView.frame = CGRect(x: 0, y: 0, width: 300, height: height)

    previewWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: height),
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

    if let screen = NSScreen.main {
        let screenRect = screen.visibleFrame
        let windowX = screenRect.maxX - 300 - 30
        let windowY = screenRect.maxY - height - 30
        previewWindow?.setFrameOrigin(NSPoint(x: windowX, y: windowY))
    }

    previewWindow?.orderFront(nil)
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        previewWindow?.orderOut(nil)
        previewWindow = nil
    }
}


//func showColorPreviewWindowBackend() {
//    @AppStorage("previewSeconds") var seconds: Double = 5.0
//
//    let hostingView = NSHostingView(rootView: ColorPreviewView())
//    hostingView.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
//
//    colorWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
//                           styleMask: .borderless,
//                           backing: .buffered,
//                           defer: false)
//    colorWindow?.contentView = hostingView
//    colorWindow?.contentView?.wantsLayer = true
//    colorWindow?.contentView?.layer?.cornerRadius = 10
//    colorWindow?.contentView?.layer?.masksToBounds = true
//    colorWindow?.level = .floating
//    colorWindow?.isOpaque = false
//    colorWindow?.backgroundColor = .clear
//
//    //    notificationWindow?.center()
//    if let screen = NSScreen.main {
//        let screenRect = screen.visibleFrame
//        let windowX = screenRect.maxX - 300 - 30
//        let windowY = screenRect.maxY - 200 - 30
//        colorWindow?.setFrameOrigin(NSPoint(x: windowX, y: windowY))
//    }
//
//    colorWindow?.orderFront(nil)
//    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
//        colorWindow?.orderOut(nil)
//        colorWindow = nil
//    }
//
//}


