//
//  ImageSnipView.swift
//  Viz
//
//  Created by Alin Lupascu on 8/29/25.
//

import SwiftUI
import AlinFoundation

struct ImageSnipView: View {
    let imageURL: URL
    @State private var image: NSImage?
    @State private var selectionRect: CGRect = .zero
    @State private var isDragging: Bool = false
    @State private var dragStart: CGPoint = .zero
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            if let image = image {
                GeometryReader { geometry in
                    ZStack {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        // Selection overlay
                        Rectangle()
                            .stroke(Color.blue, lineWidth: 2)
                            .background(Color.blue.opacity(0.1))
                            .frame(width: selectionRect.width, height: selectionRect.height)
                            .position(x: selectionRect.midX, y: selectionRect.midY)
                            .opacity(selectionRect != .zero ? 1 : 0)
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
                                
                                selectionRect = CGRect(x: minX, y: minY, width: width, height: height)
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
                
                HStack(spacing: 15) {
                    Button("Extract Text/Barcode") {
                        extractFromSelection()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectionRect == .zero)
                    
                    Button("Clear Selection") {
                        selectionRect = .zero
                    }
                    .buttonStyle(.bordered)
                    .disabled(selectionRect == .zero)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            } else {
                Text("Loading image...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color("bg"))
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        if let nsImage = NSImage(contentsOf: imageURL) {
            self.image = nsImage
        }
    }
    
    private func extractFromSelection() {
        guard let image = image, selectionRect != .zero else { return }
                
        // Crop the image based on selection
        if let croppedImage = cropImage(image: image, rect: selectionRect) {
            TextRecognition(recognizedContent: RecognizedContent.shared, image: croppedImage, historyState: HistoryState.shared) {
                showPreviewWindow(contentView: PreviewContentView())
            }.recognizeContent()
            
            dismiss()
        }
    }
    
    private func cropImage(image: NSImage, rect: CGRect) -> NSImage? {
        let imageSize = image.size
        
        // Convert selection rect to image coordinates (simplified)
        let cropRect = CGRect(
            x: rect.minX / 800 * imageSize.width,
            y: rect.minY / 600 * imageSize.height,
            width: rect.width / 800 * imageSize.width,
            height: rect.height / 600 * imageSize.height
        )
        
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return nil }
        
        return NSImage(cgImage: croppedCGImage, size: NSSize(width: croppedCGImage.width, height: croppedCGImage.height))
    }
}
