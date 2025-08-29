//
//  OCR.swift
//  Grabber
//
//  Created by Alin Lupascu on 4/5/24.
//

import SwiftUI
import Vision
import Foundation
import AlinFoundation


struct TextRecognition {
    @AppStorage("appendRecognizedText") var appendRecognizedText: Bool = false
    @AppStorage("postcommands") var postCommands: String = "say [ocr];"
    @AppStorage("processing") var processingIsEnabled: Bool = false

    let appState = AppState.shared

    var recognizedContent = RecognizedContent.shared
    var image: NSImage
    var historyState: HistoryState
    var didFinishRecognition: () -> Void

    //MARK: Universal Recognition
    func recognizeContent() {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        var recognizedText = ""
        var recognizedBarcodes = ""

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let textRequest = self.getTextRecognitionRequest { text in
                    recognizedText = text
                }
                let barcodeRequest = self.getBarcodeRecognitionRequest { barcodes in
                    recognizedBarcodes = barcodes
                }
                
                try requestHandler.perform([textRequest, barcodeRequest])

                DispatchQueue.main.async {
                    let combinedText = [recognizedText, recognizedBarcodes]
                        .filter { !$0.isEmpty && !$0.hasPrefix("Unable to extract") }
                        .joined(separator: "\n")
                    
                    let finalItem = TextItem(text: combinedText.isEmpty ? "Unable to extract any content from selection" : combinedText)
                    self.processRecognitionResult(textItem: finalItem, failureMessage: "Unable to extract any content from selection")
                }
            } catch {
                printOS("Failed to recognize content: \(error.localizedDescription)")
            }
        }
    }

    private func getTextRecognitionRequest(completion: @escaping (String) -> Void) -> VNRecognizeTextRequest {
        @AppStorage("keepLineBreaks") var keepLineBreaks: Bool = true

        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { 
                completion("Unable to extract any text from selection")
                return 
            }

            var recognizedText = ""
            for observation in observations {
                guard let text = observation.topCandidates(1).first else { continue }
                recognizedText += text.string
                if keepLineBreaks {
                    recognizedText += "\n"
                } else {
                    recognizedText += " "
                }
            }

            if recognizedText.isEmpty {
                completion("Unable to extract any text from selection")
            } else if keepLineBreaks {
                completion(recognizedText.trimmingCharacters(in: .whitespacesAndNewlines))
            } else {
                completion(recognizedText)
            }
        }

        request.recognitionLevel = appState.selectedQuality == .fast ? .fast : .accurate
        request.usesLanguageCorrection = true
        if let langCode = appState.selectedLanguage.code {
            request.recognitionLanguages = [langCode]
        }

        return request
    }

    private func getBarcodeRecognitionRequest(completion: @escaping (String) -> Void) -> VNDetectBarcodesRequest {
        @AppStorage("keepLineBreaks") var keepLineBreaks: Bool = true

        let request = VNDetectBarcodesRequest { request, error in
            guard let observations = request.results as? [VNBarcodeObservation] else { 
                completion("Unable to extract any qr/barcode from selection")
                return 
            }

            var barcodeText = ""
            for observation in observations {
                let barcodeValue = observation.payloadStringValue ?? "Unknown value"
                barcodeText += barcodeValue
                if keepLineBreaks {
                    barcodeText += "\n"
                } else {
                    barcodeText += " "
                }
            }

            if barcodeText.isEmpty {
                completion("Unable to extract any qr/barcode from selection")
            } else if keepLineBreaks {
                completion(barcodeText.trimmingCharacters(in: .whitespacesAndNewlines))
            } else {
                completion(barcodeText)
            }
        }

        return request
    }


    // Helper function
    private func processRecognitionResult(textItem: TextItem, failureMessage: String) {
        self.updateRecognizedContent(with: textItem)
        self.didFinishRecognition()

        guard textItem.text != failureMessage else { return }

        copyTextItemsToClipboard(textItems: self.recognizedContent.items)
        playSound(for: .text(TextItem(text: "")))
        historyState.historyItems.append(.text(textItem))
        if processingIsEnabled {
            updateOnMain {
                AppState.shared.cmdOutput = "Running post-processing commands.."
            }
            Task(priority: .userInitiated) {
                let combinedText = self.recognizedContent.items.map { $0.text }.joined(separator: "\n")
                let command = replaceContentToken(in: postCommands, with: combinedText)
                let result = executeShellCommand(command)
                updateOnMain {
                    AppState.shared.cmdOutput = result
                }
            }
        }
    }

    private func updateRecognizedContent(with textItem: TextItem) {
        if appendRecognizedText {
            recognizedContent.items.append(textItem)
        } else {
            recognizedContent.items = [textItem]
        }
    }

}





class CaptureService {
    @AppStorage("postcommands") var postCommands: String = "say [ocr];"

    static let shared = CaptureService()
    var screenCaptureUtility = ScreenCaptureUtility()
    var recognizedContent = RecognizedContent.shared
    let pasteboard = NSPasteboard.general

    func captureContent() {
        updateOnMain {
            AppState.shared.cmdOutput = ""
        }
        screenCaptureUtility.captureScreenSelectionToClipboard { capturedImage in
            if let image = capturedImage {

                TextRecognition(recognizedContent: self.recognizedContent, image: image, historyState: HistoryState.shared) {
                    showPreviewWindow(contentView: PreviewContentView())
                }.recognizeContent()
            } else {
                printOS("Failed to capture image")
            }
        }
    }


}
