//
//  SettingsView.swift
//  Viz
//
//  Created by Alin Lupascu on 3/27/25.
//

import Foundation
import SwiftUI
import AlinFoundation
import KeyboardShortcuts
import AVFoundation

struct SettingsView: View {
    @AppStorage("appendRecognizedText") var appendRecognizedText: Bool = false
    @AppStorage("keepLineBreaks") var keepLineBreaks: Bool = true
    @AppStorage("showPreview") var showPreview: Bool = true
    @AppStorage("previewSeconds") var seconds: Double = 5.0
    @AppStorage("processing") var processingIsEnabled: Bool = false
    @AppStorage("postcommands") var postCommands: String = "say [ocr];"
    @AppStorage("mute") var mute: Bool = false
    @AppStorage("viewWidth") var viewWidth: Double = 300.0
    @AppStorage("viewHeight") var viewHeight: Double = 200.0
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView(
                appendRecognizedText: $appendRecognizedText,
                keepLineBreaks: $keepLineBreaks,
                showPreview: $showPreview,
                seconds: $seconds,
                processingIsEnabled: $processingIsEnabled,
                postCommands: $postCommands,
                mute: $mute,
                viewWidth: $viewWidth,
                viewHeight: $viewHeight
            )
            .tabItem {
                Image(systemName: "gear")
                Text("General")
            }
            .tag(0)
            
            ShortcutsSettingsView()
            .tabItem {
                Image(systemName: "keyboard")
                Text("Shortcuts")
            }
            .tag(1)
            
            ReverseImageSearchView()
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Image Search")
            }
            .tag(2)
            
            WebcamSettingsView()
            .tabItem {
                Image(systemName: "camera")
                Text("Webcam")
            }
            .tag(3)
        }
        .frame(maxWidth: 500, maxHeight: .infinity)
        .background(Color("bg"))
        .environment(\.colorScheme, .dark)
        .preferredColorScheme(.dark)
    }
}

struct GeneralSettingsView: View {
    @Binding var appendRecognizedText: Bool
    @Binding var keepLineBreaks: Bool
    @Binding var showPreview: Bool
    @Binding var seconds: Double
    @Binding var processingIsEnabled: Bool
    @Binding var postCommands: String
    @Binding var mute: Bool
    @Binding var viewWidth: Double
    @Binding var viewHeight: Double
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .center) {
            GroupBox {
                VStack(alignment: .leading, spacing: 10) {

                    HStack {
                        Text("OCR Language")
                        Spacer()
                        LanguagePickerView()
                            .frame(width: 200)
                    }
                    HStack {
                        Text("OCR Quality")
                        Spacer()
                        QualityPickerView()
                            .frame(width: 200)
                    }

                    Toggle("Append consecutive captures", isOn: $appendRecognizedText)
                        .toggleStyle(SpacedToggle())
                        .help("When enabled, consecutive captures will be added on to the previous capture")

                    Toggle("Keep line breaks in captures", isOn: $keepLineBreaks)
                        .toggleStyle(SpacedToggle())
                        .help("New lines will be kept from scanned text")

                    Toggle("Show capture window for", isOn: $showPreview)
                        .toggleStyle(SpacedToggleSeconds())
                        .help("When enabled, captured content preview will show and close after \(Int(seconds)) seconds. Otherwise it's not shown at all.")

                    Toggle("Post-processing", isOn: $processingIsEnabled)
                        .toggleStyle(SpacedProcessingToggle())
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

                    HStack {
                        Text("Capture Window Dimensions")
                            .help("The size of the window that shows the captured content at the top right of the screen")
                        Spacer()
                        HStack() {
                            Text("W:")
                            Stepper("\(Int(viewWidth))", value: $viewWidth, in: 200...1000, step: 10)
                                .frame(width: 60, alignment: .trailing)
                            Text("H:")
                            Stepper("\(Int(viewHeight))", value: $viewHeight, in: 100...1000, step: 10)
                                .frame(width: 60, alignment: .trailing)
                        }

                        Button {
                            viewWidth = 300.0
                            viewHeight = 200.0
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 12))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                        .help("Reset dimensions to default")

                        Button {
                            showPreviewWindow(contentView: PreviewContentView())
                        } label: {
                            Image(systemName: "macwindow")
                                .font(.system(size: 12))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                        .help("Show example window")
                    }
                }
                .padding()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct ShortcutsSettingsView: View {
    var body: some View {
        VStack(alignment: .center) {
            GroupBox {
                VStack(spacing: 10) {
                    HStack {
                        Text("Capture Content")
                        Spacer()
                        KeyboardShortcuts.Recorder(for: .captureContent)
                    }
                    HStack {
                        Text("Color Picker")
                        Spacer()
                        KeyboardShortcuts.Recorder(for: .eyedropper)
                    }
                    HStack {
                        Text("History Window")
                        Spacer()
                        KeyboardShortcuts.Recorder(for: .history)
                    }
                    HStack {
                        Text("Clear Clipboard")
                        Spacer()
                        KeyboardShortcuts.Recorder(for: .clear)
                    }
                }
                .padding()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct ReverseImageSearchView: View {
    var body: some View {
        VStack(alignment: .center) {
            GroupBox {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Reverse image search features will be added here")
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct WebcamDevice: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
}

class WebcamManager: ObservableObject {
    @Published var availableDevices: [WebcamDevice] = []
    @Published var defaultDevice: WebcamDevice?
    @Published var isPreviewActive: Bool = false
    @Published var permissionStatus: String = "Checking..."
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            if status == .authorized {
                return true
            }
            
            if status == .notDetermined {
                return await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return false
        }
    }
    
    init() {
        loadAvailableDevices()
    }
    
    func loadAvailableDevices() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .externalUnknown],
            mediaType: .video,
            position: .unspecified
        )
        
        var devices: [WebcamDevice] = []
        var builtInDevice: WebcamDevice?
        
        for device in discoverySession.devices {
            let webcamDevice = WebcamDevice(id: device.uniqueID, name: device.localizedName)
            devices.append(webcamDevice)
            
            if device.deviceType == .builtInWideAngleCamera {
                builtInDevice = webcamDevice
            }
        }
        
        self.availableDevices = devices
        self.defaultDevice = builtInDevice ?? devices.first
    }
    
    func checkPermissions() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            permissionStatus = "Camera access granted"
        } else {
            permissionStatus = "Camera access denied - Check System Settings > Privacy & Security > Camera"
        }
    }
    
    func setUpCaptureSession(for deviceID: String) async -> AVCaptureVideoPreviewLayer? {
        guard await isAuthorized else { 
            await MainActor.run {
                self.checkPermissions()
            }
            return nil 
        }
        
        await stopPreview()
        
        guard let device = AVCaptureDevice(uniqueID: deviceID) else { return nil }
        
        let session = AVCaptureSession()
        session.sessionPreset = .medium
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            let layer = AVCaptureVideoPreviewLayer(session: session)
            layer.videoGravity = .resizeAspectFill
            
            session.startRunning()
            
            await MainActor.run {
                self.captureSession = session
                self.previewLayer = layer
                self.isPreviewActive = true
                self.permissionStatus = "Camera preview active"
            }
            
            return layer
        } catch {
            await MainActor.run {
                self.permissionStatus = "Error starting camera: \(error.localizedDescription)"
            }
            return nil
        }
    }
    
    func stopPreview() async {
        await MainActor.run {
            captureSession?.stopRunning()
            captureSession = nil
            previewLayer = nil
            isPreviewActive = false
        }
    }
}

struct CameraPreviewView: NSViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.layer = previewLayer
        view.wantsLayer = true
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        nsView.layer = previewLayer
        previewLayer.frame = nsView.bounds
    }
}

struct WebcamSettingsView: View {
    @AppStorage("selectedWebcamID") private var selectedWebcamID: String = ""
    @StateObject private var webcamManager = WebcamManager()
    @State private var previewLayer: AVCaptureVideoPreviewLayer?
    @State private var windowObserver: NSObjectProtocol?
    
    var selectedWebcam: WebcamDevice? {
        if selectedWebcamID.isEmpty {
            return webcamManager.defaultDevice
        }
        return webcamManager.availableDevices.first { $0.id == selectedWebcamID }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            GroupBox {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Default Camera")
                        Spacer()
                        Picker("", selection: Binding(
                            get: { selectedWebcam ?? webcamManager.defaultDevice ?? webcamManager.availableDevices.first },
                            set: { device in 
                                selectedWebcamID = device?.id ?? ""
                                updatePreview()
                            }
                        )) {
                            ForEach(webcamManager.availableDevices) { device in
                                Text(device.name).tag(device as WebcamDevice?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 200)
                        
                        Button {
                            webcamManager.loadAvailableDevices()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 12))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                        .help("Scan for newly connected cameras")
                    }
                    
                    HStack {
                        Text("Status:")
                        Text(webcamManager.permissionStatus)
                            .foregroundStyle(.secondary)
                        Spacer()
                        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
                            Button("Open System Settings") {
                                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera")!)
                            }
                        }
                    }
                }
                .padding()
            }
            
            VStack {
                if let previewLayer = previewLayer {
                    CameraPreviewView(previewLayer: previewLayer)
                        .frame(width: 320, height: 240)
                        .background(Color.black)
                        .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 320, height: 240)
                        .cornerRadius(8)
                        .overlay {
                            VStack {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.gray)
                                Text("Camera Preview")
                                    .foregroundStyle(.gray)
                            }
                        }
                }
            }
            .padding()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            setupWindowObserver()
            webcamManager.checkPermissions()
            if selectedWebcamID.isEmpty {
                selectedWebcamID = webcamManager.defaultDevice?.id ?? ""
            }
            
            updatePreview()
        }
        .onDisappear {
            Task {
                await webcamManager.stopPreview()
            }
            removeWindowObserver()
        }
    }
    
    private func updatePreview() {
        guard let deviceID = selectedWebcam?.id else { return }
        
        Task {
            if let layer = await webcamManager.setUpCaptureSession(for: deviceID) {
                await MainActor.run {
                    previewLayer = layer
                }
            }
        }
    }
    
    private func setupWindowObserver() {
        windowObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Check if permission status changed when returning from System Settings
            let previousStatus = webcamManager.permissionStatus
            webcamManager.checkPermissions()
            
            // If permission was just granted, start preview
            if previousStatus.contains("denied") && AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                updatePreview()
            }
        }
    }
    
    private func removeWindowObserver() {
        if let observer = windowObserver {
            NotificationCenter.default.removeObserver(observer)
            windowObserver = nil
        }
    }
}
