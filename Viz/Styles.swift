//
//  Styles.swift
//  Viz
//
//  Created by Alin Lupascu on 6/3/24.
//

import Foundation
import SwiftUI
import KeyboardShortcuts
import AlinFoundation


struct InfoButton: View {
    @State private var isPopoverPresented: Bool = false
    let text: String
    let color: Color
    let label: String
    let warning: Bool

    init(text: String, color: Color = .primary, label: String = "", warning: Bool = false) {
        self.text = text
        self.color = color
        self.label = label
        self.warning = warning

    }

    var body: some View {
        Button(action: {
            self.isPopoverPresented.toggle()
        }) {
            HStack(alignment: .center, spacing: 5) {
                Image(systemName: !warning ? "info.circle.fill" : "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundColor(!warning ? color.opacity(0.7) : color)
                    .frame(height: 16)
                if !label.isEmpty {
                    Text(label)
                        .font(.callout)
                        .foregroundColor(color.opacity(0.7))

                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { isHovered in
            if isHovered {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        .popover(isPresented: $isPopoverPresented, arrowEdge: .bottom) {
            VStack {
                Spacer()
                Text(text)
                    .font(.callout)
                    .frame(maxWidth: .infinity)
                    .padding()
                Spacer()
            }
            .frame(width: 300)
        }
        .padding(.horizontal, 5)
    }
}


struct SimpleButtonBrightStyle: ButtonStyle {
    @State private var hovered = false
    let icon: String
    let help: String
    let color: Color
    let shield: Bool?

    init(icon: String, help: String, color: Color, shield: Bool? = nil) {
        self.icon = icon
        self.help = help
        self.color = color
        self.shield = shield
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20)
                .foregroundColor(hovered ? color.opacity(0.5) : color)
        }
        .padding(5)
        .onHover { hovering in
            withAnimation() {
                hovered = hovering
            }
        }
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
        .help(help)
    }
}


struct RoundedRectangleButtonStyle: ButtonStyle {
    @State private var isHovered = false
    let image: String
    let size: CGFloat
    let color: Color?
    let shortcut: KeyboardShortcuts.Shortcut?

    init(image: String, size: CGFloat, color: Color? = .primary, shortcut: KeyboardShortcuts.Shortcut? = nil) {
        self.image = image
        self.size = size
        self.color = color
        self.shortcut = shortcut
    }

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            VStack(alignment: .center, spacing: 10) {
                Image(systemName: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size)
                    .foregroundColor(color)
                configuration.label
                    .font(.footnote)

                if let shortcut = shortcut {
                    Text(shortcut.description)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding()
        .background(isHovered ? Color.primary.opacity(0.3) : Color.primary.opacity(0.1))
        .foregroundColor(.primary)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.primary.opacity(0.2), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.3), value: isHovered)
        .cornerRadius(10)
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .onHover { inside in
            isHovered = inside
        }
    }
}


struct ShortcutEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    let name: KeyboardShortcuts.Name

    var body: some View {
        if let shortcut = KeyboardShortcuts.getShortcut(for: name) {
            HStack(spacing: 4) {
                Text(shortcut.description)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .onTapGesture {
                        WindowManager.shared.open(id: "settings", with: SettingsView().environmentObject(appState), width: 500, height: 630)
                        dismiss()
                    }
            }
        }
    }
}



struct SpacedToggle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer() // Adds space between the label and the switch
            Switch(isOn: configuration.$isOn)
                .labelsHidden() // Hide default labels of the switch to use the custom label
        }
    }
}

struct SpacedToggleSeconds: ToggleStyle {
    @AppStorage("previewSeconds") var seconds: Double = 5.0

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 0) {

            configuration.label

            Picker("", selection: $seconds) {
                Text("3s").tag(3.0)
                Text("5s").tag(5.0)
                Text("10s").tag(10.0)
                Text("20s").tag(20.0)
                Text("30s").tag(30.0)
                Text("60s").tag(60.0)
            }
            .buttonStyle(.borderless)

            Spacer() // Adds space between the label and the switch

            Switch(isOn: configuration.$isOn)
                .labelsHidden() // Hide default labels of the switch to use the custom label
        }
    }
}

struct Switch: View {
    @Binding var isOn: Bool

    var body: some View {
        Toggle("", isOn: $isOn)
            .toggleStyle(.switch)
    }
}


struct SimpleSearchStyle: TextFieldStyle {
    @State private var isHovered = false
    @State var trash: Bool = false
    @EnvironmentObject var appState: AppState
    @AppStorage("postcommands") private var text: String = ""

    func _body(configuration: TextField<Self._Label>) -> some View {

        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.clear)
                .allowsHitTesting(false)
                .frame(height: 30)

            ZStack {
                HStack {
                    configuration
                        .font(.title3)
                        .foregroundColor(.clear)
                        .textFieldStyle(PlainTextFieldStyle())

                    Spacer()

                    if trash && text != "" {
                        Button("") {
                            text = ""
                        }
                        .buttonStyle(SimpleButtonStyle(icon: "xmark.circle.fill", help: "Clear text", size: 14, padding: 0))
                    }
                }

            }
            .padding(.horizontal, 8)

        }
        .onHover { hovering in
            withAnimation(Animation.easeInOut(duration: 0.15)) {
                self.isHovered = hovering
            }
        }
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

// Hide blinking textfield caret
extension NSTextView {
    open override var frame: CGRect {
        didSet {
            insertionPointColor = NSColor(named: "mode")//.clear
        }
    }
}


struct SimpleButtonStyle: ButtonStyle {
    @State private var hovered = false
    let icon: String
    let iconFlip: String
    let label: String
    let help: String
    let color: Color
    let size: CGFloat
    let padding: CGFloat
    let rotate: Bool

    init(icon: String, iconFlip: String = "", label: String = "", help: String, color: Color = .primary, size: CGFloat = 20, padding: CGFloat = 5, rotate: Bool = false) {
        self.icon = icon
        self.iconFlip = iconFlip
        self.label = label
        self.help = help
        self.color = color
        self.size = size
        self.padding = padding
        self.rotate = rotate
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        HStack(alignment: .center) {
            Image(systemName: (hovered && !iconFlip.isEmpty) ? iconFlip : icon)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .scaleEffect(hovered ? 1.1 : 1.0)
                .rotationEffect(.degrees(rotate ? (hovered ? 90 : 0) : 0))
                .animation(.easeInOut(duration: 0.2), value: hovered)
            if !label.isEmpty {
                Text(label)
            }
        }
        .foregroundColor(hovered ? color : color.opacity(0.5))
        .padding(padding)
        .onHover { hovering in
            withAnimation() {
                hovered = hovering
            }
        }
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
        .help(help)
    }
}
