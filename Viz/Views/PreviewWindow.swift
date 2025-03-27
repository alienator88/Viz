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
                        Spacer()

                        Button("Close") {
                            previewWindow?.orderOut(nil)
                            previewWindow = nil
                        }
                        .buttonStyle(SimpleButtonStyle(icon: "x.circle.fill", help: "Close", color: Color("mode"), size: 14))
                    }

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
                    //                    .padding(.top, 5)
                    .scrollIndicators(.visible)
                    .textSelection(.enabled)

                }
                    .padding()
                    .foregroundColor(Color("mode"))
                    .onTapGesture {
                        previewWindow?.orderOut(nil)
                        previewWindow = nil
                    }
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
                        Spacer()

                        Button("Close") {
                            previewWindow?.orderOut(nil)
                            previewWindow = nil
                        }
                        .buttonStyle(SimpleButtonStyle(icon: "x.circle.fill", help: "Close", color: Color("mode"), size: 14))
                    }

                    ScrollView {
                        Text(cmdOutput.isEmpty ? "No output to display" : cmdOutput)
                            .padding(4)
                            .textSelection(.enabled)
                    }

                }
                    .padding()
                    .foregroundColor(Color("mode"))
                    .onTapGesture {
                        cmdOutputWindow?.orderOut(nil)
                        cmdOutputWindow = nil
                    }
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
                        Spacer()

                        Button("Close") {
                            previewWindow?.orderOut(nil)
                            previewWindow = nil
                        }
                        .buttonStyle(SimpleButtonStyle(icon: "x.circle.fill", help: "Close", color: Color("mode"), size: 14))
                    }

                    if AppState.shared.colorSample.hex.isEmpty {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("No color selected")
                                .foregroundColor(.secondary)
                            Spacer()
                        }

                        Spacer()
                    } else {
                        Text("Hex: \(AppState.shared.colorSample.hex)")
                        Text("RGB: \(AppState.shared.colorSample.rgb)")
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppState.shared.colorSample.color)
                    }



                }
                    .padding()
                    .foregroundColor(Color("mode"))
                    .onTapGesture {
                        colorWindow?.orderOut(nil)
                        colorWindow = nil
                    }
            )


    }
}



struct HistoryView: View {
    @ObservedObject private var historyState = HistoryState.shared
    @State private var tappedItemID: String?
    @State private var filterSelection = "All"
    private let filters = ["All", "Text", "Colors"]
    private var filteredItems: [HistoryEntry] {
        historyState.historyItems
            .reversed()
            .filter { item in
                switch filterSelection {
                case "Text":
                    if case .text = item { return true }
                    return false
                case "Colors":
                    if case .color = item { return true }
                    return false
                default:
                    return true
                }
            }
    }

    var body: some View {

        VStack(alignment: .center, spacing: 0) {

            Text("History")
                .font(.title)
                .padding(.vertical)

            Spacer()

            if filteredItems.isEmpty {
                Text(filterSelection == "All" ? "No items have been captured" : filterSelection == "Text" ? "No text has been captured" : "No colors have been captured").foregroundStyle(.secondary)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(filteredItems) { item in
                            HStack {
                                switch item {
                                case .color(let colorItem):
                                    HStack(alignment: .center, spacing: 0) {
                                        VStack(alignment: .leading) {
                                            Text("HEX: \(colorItem.hex)")
                                            Text("RGB: \(colorItem.rgb)")
                                                .font(.footnote)
                                                .foregroundStyle(.secondary)
                                                .onTapGesture {
                                                    tappedItemID = colorItem.id
                                                    copyToClipboard(colorItem.rgb)
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                        tappedItemID = nil
                                                    }
                                                }
                                        }
                                        .frame(width: 100)
                                        .padding()
                                        TrailingRoundedRectangle(cornerRadius: 8)
                                            .fill(colorItem.color)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .background {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.secondary.opacity(0.1))
                                    }
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(.secondary.opacity(0.3))
                                    }
                                    .animation(.easeInOut(duration: 0.2), value: tappedItemID)
                                    .onTapGesture {
                                        tappedItemID = colorItem.id
                                        copyToClipboard(colorItem.hex)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            tappedItemID = nil
                                        }
                                    }
                                case .text(let textItem):
                                    HStack {
                                        HStack(alignment: .center, spacing: 0) {
                                            Text(textItem.text)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .padding()
                                        .background {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(.secondary.opacity(0.1))
                                        }
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 8)
                                                .strokeBorder(.secondary.opacity(0.3))
                                        }
                                        .animation(.easeInOut(duration: 0.2), value: tappedItemID)
                                        .onTapGesture {
                                            tappedItemID = textItem.id
                                            copyToClipboard(textItem.text)
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                tappedItemID = nil
                                            }
                                        }
                                    }
                                }


                                // Delete item button
                                Button(action: {
                                    switch item {
                                    case .text(let textItem):
                                        if tappedItemID != textItem.id {
                                            historyState.historyItems.removeAll { $0.id == item.id }
                                        }
                                    case .color(let colorItem):
                                        if tappedItemID != colorItem.id {
                                            historyState.historyItems.removeAll { $0.id == item.id }
                                        }
                                    }
                                }) {
                                    Image(systemName: tappedItemID == item.id ? "checkmark" : "xmark.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 14, height: 14)
                                        .foregroundColor(tappedItemID == item.id ? .green : .secondary)
                                        .padding(.horizontal, 5)
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                }
                .scrollIndicators(.never)
            }

            Spacer()

            HStack {
                Picker("", selection: $filterSelection) {
                    ForEach(filters, id: \.self) { filter in
                        Text(filter).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 150)

                Spacer()

                Button {
                    clearClipboard()
                } label: {
                    Image(systemName: "trash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .padding(5)
                        .padding(.leading, 1)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            .padding(.vertical)


        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)

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



struct TrailingRoundedRectangle: Shape {
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(0),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}
