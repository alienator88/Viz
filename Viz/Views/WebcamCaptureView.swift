//
//  WebcamCaptureView.swift
//  Viz
//
//  Created by Alin Lupascu on 8/29/25.
//

@preconcurrency import AVFoundation
import AlinFoundation
import SwiftUI

class WebcamCaptureManager: ObservableObject {
    @Published var capturedImage: NSImage?
    @Published var isPreviewActive: Bool = false

    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var lastSampleBuffer: CMSampleBuffer?
    private var videoDelegate: VideoSampleDelegate?
    private var shouldBeRunning: Bool = false

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

    func setUpCaptureSession() async -> AVCaptureVideoPreviewLayer? {
        guard await isAuthorized else { return nil }

        await stopSession()

        // Mark that we want the session to be running
        await MainActor.run {
            self.shouldBeRunning = true
        }

        let selectedWebcamID = UserDefaults.standard.string(forKey: "selectedWebcamID") ?? ""
        let device: AVCaptureDevice?

        if selectedWebcamID.isEmpty {
            device = AVCaptureDevice.default(for: .video)
        } else {
            device = AVCaptureDevice(uniqueID: selectedWebcamID)
        }

        guard let captureDevice = device else { return nil }

        let session = AVCaptureSession()
        session.sessionPreset = .high

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if session.canAddInput(input) {
                session.addInput(input)
            }

            let videoOutput = AVCaptureVideoDataOutput()
            let delegate = VideoSampleDelegate { buffer in
                self.lastSampleBuffer = buffer
            }
            videoOutput.setSampleBufferDelegate(delegate, queue: DispatchQueue(label: "videoQueue"))

            // Store delegate to prevent deallocation
            await MainActor.run {
                self.videoDelegate = delegate
            }

            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }

            let layer = AVCaptureVideoPreviewLayer(session: session)
            layer.videoGravity = .resizeAspectFill

            session.startRunning()

            // Check if we should still be running (window might have closed during setup)
            let stillShouldRun = await MainActor.run { self.shouldBeRunning }
            if !stillShouldRun {
                // Window was closed during setup, stop immediately
                session.stopRunning()
                return nil
            }

            await MainActor.run { [captureSession = session, videoOutput = videoOutput] in
                self.captureSession = captureSession
                self.videoOutput = videoOutput
                self.isPreviewActive = true
            }

            // Use Task.detached to avoid Sendable capture issues
            Task { @MainActor in
                self.previewLayer = layer
            }

            return layer
        } catch {
            print("Error setting up webcam capture: \(error)")
            return nil
        }
    }

    func capturePhoto() {
        guard let sampleBuffer = lastSampleBuffer else {
            print("No sample buffer available")
            return
        }

        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get image buffer")
            return
        }

        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let context = CIContext()

        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            print("Failed to create CGImage")
            return
        }

        let nsImage = NSImage(
            cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))

        DispatchQueue.main.async {
            self.capturedImage = nsImage
        }
    }

    func clearCapturedImage() {
        capturedImage = nil
    }

    func stopSession() async {
        await MainActor.run {
            shouldBeRunning = false
            captureSession?.stopRunning()
            captureSession = nil
            videoOutput = nil
            previewLayer = nil
            isPreviewActive = false
            lastSampleBuffer = nil
            videoDelegate = nil
        }
    }
}

class VideoSampleDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let bufferHandler: (CMSampleBuffer) -> Void

    init(bufferHandler: @escaping (CMSampleBuffer) -> Void) {
        self.bufferHandler = bufferHandler
    }

    func captureOutput(
        _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        bufferHandler(sampleBuffer)
    }
}

struct WebcamCaptureView: View {
    @StateObject private var captureManager = WebcamCaptureManager()
    @StateObject private var webcamManager = WebcamManager()
    @AppStorage("selectedWebcamID") private var selectedWebcamID: String = ""
    @State private var previewLayer: AVCaptureVideoPreviewLayer?
    @State private var isSnipping: Bool = false
    @State private var selectionRect: CGRect = .zero
    @State private var isDragging: Bool = false
    @State private var dragStart: CGPoint = .zero
    @State private var viewSize: CGSize = .zero
    @State private var permissionDenied: Bool = false
    @Environment(\.dismiss) private var dismiss

    var selectedWebcam: WebcamDevice? {
        if selectedWebcamID.isEmpty {
            return webcamManager.defaultDevice
        }
        return webcamManager.availableDevices.first { $0.id == selectedWebcamID }
    }

    var body: some View {
        ZStack {
            // Full window content
            if let capturedImage = captureManager.capturedImage {
                if isSnipping {
                    GeometryReader { geometry in
                        ZStack {
                            Image(nsImage: capturedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()

                            // Selection overlay
                            Rectangle()
                                .stroke(Color.blue, lineWidth: 2)
                                .background(Color.blue.opacity(0.1))
                                .frame(width: selectionRect.width, height: selectionRect.height)
                                .position(x: selectionRect.midX, y: selectionRect.midY)
                                .opacity(selectionRect != .zero ? 1 : 0)
                        }
                        .onAppear {
                            viewSize = geometry.size
                        }
                        .onChange(of: geometry.size) { newSize in
                            viewSize = newSize
                        }
                        .gesture(
                            DragGesture(coordinateSpace: .local)
                                .onChanged { value in
                                    if !isDragging {
                                        isDragging = true
                                        dragStart = value.startLocation
                                    }

                                    let currentLocation = value.location
                                    let minX = min(dragStart.x, currentLocation.x)
                                    let minY = min(dragStart.y, currentLocation.y)
                                    let width = abs(currentLocation.x - dragStart.x)
                                    let height = abs(currentLocation.y - dragStart.y)

                                    selectionRect = CGRect(
                                        x: minX, y: minY, width: width, height: height)
                                }
                                .onEnded { _ in
                                    isDragging = false
                                }
                        )
                    }
                    .background(Color.black)
                    .onHover { isHovering in
                        if isHovering {
                            NSCursor.crosshair.set()
                        } else {
                            NSCursor.arrow.set()
                        }
                    }
                } else {
                    Image(nsImage: capturedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .background(Color.black)
                }
            } else if let previewLayer = previewLayer {
                ZStack(alignment: .bottom) {
                    CameraPreviewView(previewLayer: previewLayer)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Button {
                        captureManager.capturePhoto()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 14))
                            Text("Capture")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                    .disabled(!captureManager.isPreviewActive)
                    .padding(.bottom, 20)
                }
            } else {
                Rectangle()
                    .fill(Color.black)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay {
                        VStack(spacing: 15) {
                            if permissionDenied {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.red)
                                Text("Camera access denied")
                                    .foregroundStyle(.red)
                                    .font(.headline)

                                Button {
                                    NSWorkspace.shared.open(
                                        URL(
                                            string:
                                                "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera"
                                        )!)
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "gear")
                                            .font(.system(size: 14))
                                        Text("Open Settings")
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        .ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                                }
                                .buttonStyle(.plain)
                            } else {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.gray)
                                Text("Starting Camera")
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
            }

            // Bottom toolbar overlay
            if captureManager.capturedImage != nil {
                VStack {
                    Spacer()
                    HStack {
                        if isSnipping {
                            Spacer()

                            HStack(spacing: 15) {
                                Button {
                                    extractFromSelection()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "doc.text.viewfinder")
                                            .font(.system(size: 14))
                                        Text("Extract")
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        .ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                                }
                                .buttonStyle(.plain)
                                .disabled(selectionRect == .zero)

                                Button {
                                    selectionRect = .zero
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 14))
                                        Text("Clear")
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        .ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                                }
                                .buttonStyle(.plain)
                                .disabled(selectionRect == .zero)

                                Button {
                                    isSnipping = false
                                    selectionRect = .zero
                                    captureManager.clearCapturedImage()
                                    Task {
                                        previewLayer = await captureManager.setUpCaptureSession()
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.backward")
                                            .font(.system(size: 14))
                                        Text("Back")
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        .ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                                }
                                .buttonStyle(.plain)
                            }

                            Spacer()
                        } else {
                            Spacer()

                            HStack(spacing: 15) {
                                Button {
                                    // Auto process entire image - stay on current screen
                                    TextRecognition(
                                        recognizedContent: RecognizedContent.shared,
                                        image: captureManager.capturedImage!,
                                        historyState: HistoryState.shared
                                    ) {
                                        showPreviewWindow(contentView: PreviewContentView())
                                    }.recognizeContent()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "wand.and.stars")
                                            .font(.system(size: 14))
                                        Text("Auto Extract")
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        .ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                                }
                                .buttonStyle(.plain)

                                Button {
                                    isSnipping = true
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "crop")
                                            .font(.system(size: 14))
                                        Text("Manual Extract")
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        .ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                                }
                                .buttonStyle(.plain)

                                Button {
                                    captureManager.clearCapturedImage()
                                    Task {
                                        previewLayer = await captureManager.setUpCaptureSession()
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.backward")
                                            .font(.system(size: 14))
                                        Text("Back")
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        .ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                                }
                                .buttonStyle(.plain)
                            }

                            Spacer()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
            }

            // Camera picker overlay
            if captureManager.capturedImage == nil {
                VStack {
                    HStack {
                        Spacer()

                        if webcamManager.availableDevices.count > 1 {
                            Menu {
                                ForEach(webcamManager.availableDevices) { device in
                                    Button(device.name) {
                                        let newID = device.id
                                        if newID != selectedWebcamID {
                                            selectedWebcamID = newID
                                            updateWebcamPreview()
                                        }
                                    }
                                }
                            } label: {
                                Text(selectedWebcam?.name ?? "Select Camera")
                                    .foregroundColor(.primary)
                            }
                            .buttonStyle(.plain)
                            .fixedSize()
                            .padding(6)
                            .padding(.horizontal, 2)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding()

                    Spacer()
                }
            }
        }
        .ignoresSafeArea(.all)
        .onAppear {
            webcamManager.loadAvailableDevices()
            if selectedWebcamID.isEmpty {
                selectedWebcamID = webcamManager.defaultDevice?.id ?? ""
            }
            Task {
                // Check and request permission in background
                let authorized = await captureManager.isAuthorized
                if !authorized {
                    await MainActor.run {
                        permissionDenied = true
                    }
                } else {
                    await MainActor.run {
                        permissionDenied = false
                    }
                    previewLayer = await captureManager.setUpCaptureSession()
                }
            }
        }
        .onDisappear {
            Task {
                await captureManager.stopSession()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) {
            notification in
            // Stop camera when window closes
            Task {
                await captureManager.stopSession()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) {
            notification in
            // Restart camera when window becomes key (visible) again
            guard let window = notification.object as? NSWindow,
                window.contentViewController is NSHostingController<WebcamCaptureView>,
                captureManager.capturedImage == nil,
                !captureManager.isPreviewActive
            else { return }

            Task {
                previewLayer = await captureManager.setUpCaptureSession()
            }
        }
        .onChange(of: captureManager.capturedImage) { image in
            if let image = image {
                resizeWindowToFitImage(image)
            }
        }
    }

    private func updateWebcamPreview() {
        Task {
            previewLayer = await captureManager.setUpCaptureSession()
        }
    }

    private func resizeWindowToFitImage(_ image: NSImage) {
        guard let window = NSApp.keyWindow else { return }

        let imageSize = image.size
        let aspectRatio = imageSize.width / imageSize.height

        // Calculate new window size maintaining aspect ratio
        let maxWidth: CGFloat = 1200
        let maxHeight: CGFloat = 900

        var newWidth: CGFloat
        var newHeight: CGFloat

        if aspectRatio > 1 {  // Landscape
            newWidth = min(maxWidth, imageSize.width * 0.5)
            newHeight = newWidth / aspectRatio
        } else {  // Portrait or square
            newHeight = min(maxHeight, imageSize.height * 0.5)
            newWidth = newHeight * aspectRatio
        }

        // Add space for toolbar
        newHeight += 80

        // Animate the resize
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            window.animator().setContentSize(NSSize(width: newWidth, height: newHeight))
        }
    }

    private func extractFromSelection() {
        guard let image = captureManager.capturedImage, selectionRect != .zero else { return }

        // Crop the image based on selection
        if let croppedImage = cropImage(image: image, rect: selectionRect) {
            TextRecognition(
                recognizedContent: RecognizedContent.shared, image: croppedImage,
                historyState: HistoryState.shared
            ) {
                showPreviewWindow(contentView: PreviewContentView())
            }.recognizeContent()

            // Reset to captured image view
            isSnipping = false
            selectionRect = .zero
        }
    }

    private func cropImage(image: NSImage, rect: CGRect) -> NSImage? {
        let imageSize = image.size

        // Convert selection rect to image coordinates using actual view size
        let cropRect = CGRect(
            x: rect.minX / viewSize.width * imageSize.width,
            y: rect.minY / viewSize.height * imageSize.height,
            width: rect.width / viewSize.width * imageSize.width,
            height: rect.height / viewSize.height * imageSize.height
        )

        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }

        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return nil }

        return NSImage(
            cgImage: croppedCGImage,
            size: NSSize(width: croppedCGImage.width, height: croppedCGImage.height))
    }
}

struct WebcamDevice: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
}

class WebcamManager: ObservableObject {
    @Published var availableDevices: [WebcamDevice] = []
    @Published var defaultDevice: WebcamDevice?

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

struct CapturedImageView: View {
    let image: NSImage

    var body: some View {
        Image(nsImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 480, height: 360)
            .background(Color.black)
    }
}
