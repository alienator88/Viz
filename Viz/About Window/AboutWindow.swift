import AppKit
import SwiftUI
import AlinFoundation

class AboutWindow: NSWindowController {

    static func show(updater: Updater) {
        let aboutWindow = AboutWindow(updater: updater) // Inject updater
        aboutWindow.window?.makeKeyAndOrderFront(nil)
    }
    
    convenience init(updater: Updater) { // Add updater parameter

        let window = Self.makeWindow()
        
        window.backgroundColor = NSColor.controlBackgroundColor
        
        self.init(window: window)
        
        // Using Visual Effect to make titlebar fully transparent
        let visualEffect = NSVisualEffectView()
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.material = .sidebar

        let contentView = AboutView()
            .environmentObject(updater)

        let hostView = NSHostingView(rootView: contentView)
        
        window.contentView = visualEffect
        
        visualEffect.addSubview(hostView)
        hostView.frame = visualEffect.frame
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.center()
        window.title = "Viz"
        
    }
    
    private static func makeWindow() -> NSWindow {
        let contentRect = NSRect(x: 0, y: 0, width: 400, height: 420)
        let styleMask: NSWindow.StyleMask = [
            .titled,
            .closable,
            .fullSizeContentView,
            
        ]
        return NSWindow(contentRect: contentRect,
                        styleMask: styleMask,
                        backing: .buffered,
                        defer: false)
    }

}
