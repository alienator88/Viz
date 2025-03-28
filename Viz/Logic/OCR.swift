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

    //MARK: Text Recognition
    func recognizeText() {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let textItem = TextItem(text: "")

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([self.getTextRecognitionRequest(with: textItem)])

                DispatchQueue.main.async {
                    self.processRecognitionResult(textItem: textItem, failureMessage: "Unable to extract any text from selection")
                }
            } catch {
                printOS("Failed to recognize text: \(error.localizedDescription)")
            }
        }
    }

    private func getTextRecognitionRequest(with textItem: TextItem) -> VNRecognizeTextRequest {
        @AppStorage("keepLineBreaks") var keepLineBreaks: Bool = true

        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

            for observation in observations {
                guard let recognizedText = observation.topCandidates(1).first else { continue }
                textItem.text += recognizedText.string
                if keepLineBreaks {
                    textItem.text += "\n"
                } else {
                    textItem.text += " "
                }
            }

            // Check if textItem.text is empty, set to "Nothing captured" if it is
            if textItem.text.isEmpty {
                textItem.text = "Unable to extract any text from selection"
            } else if keepLineBreaks {
                // Remove the last newline if keepLineBreaks is true
                textItem.text = textItem.text.trimmingCharacters(in: .whitespacesAndNewlines)
            }

        }

        request.recognitionLevel = appState.selectedQuality == .fast ? .fast : .accurate
        request.usesLanguageCorrection = true
        if let langCode = appState.selectedLanguage.code {
            request.recognitionLanguages = [langCode]
        }

        return request
    }


    //MARK: Barcode Recognition
    func recognizeBarcodes() {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let barcodeItem = TextItem(text: "")

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([self.getBarcodeRecognitionRequest(with: barcodeItem)])

                DispatchQueue.main.async {
                    self.processRecognitionResult(textItem: barcodeItem, failureMessage: "Unable to extract any qr/barcode from selection")
                }
            } catch {
                printOS("Failed to recognize barcodes: \(error.localizedDescription)")
            }
        }
    }

    private func getBarcodeRecognitionRequest(with textItem: TextItem) -> VNDetectBarcodesRequest {
        @AppStorage("keepLineBreaks") var keepLineBreaks: Bool = true

        let request = VNDetectBarcodesRequest { request, error in
            guard let observations = request.results as? [VNBarcodeObservation] else { return }

            for observation in observations {
                let barcodeValue = observation.payloadStringValue ?? "Unknown value"
                textItem.text += barcodeValue
                if keepLineBreaks {
                    textItem.text += "\n"
                } else {
                    textItem.text += " "
                }
            }

            // Check if textItem.text is empty, set to "Nothing captured" if it is
            if textItem.text.isEmpty {
                textItem.text = "Unable to extract any qr/barcode from selection"
            } else if keepLineBreaks {
                // Remove the last newline if keepLineBreaks is true
                textItem.text = textItem.text.trimmingCharacters(in: .whitespacesAndNewlines)
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

    func captureText() {
        updateOnMain {
            AppState.shared.cmdOutput = ""
        }
        screenCaptureUtility.captureScreenSelectionToClipboard { capturedImage in
            if let image = capturedImage {

                TextRecognition(recognizedContent: self.recognizedContent, image: image, historyState: HistoryState.shared) {
                    showPreviewWindow(contentView: PreviewContentView())
                }.recognizeText()
            } else {
                printOS("Failed to capture image")
            }
        }
    }

    func captureBarcodes() {
        updateOnMain {
            AppState.shared.cmdOutput = ""
        }
        screenCaptureUtility.captureScreenSelectionToClipboard { capturedImage in
            if let image = capturedImage {

                TextRecognition(recognizedContent: self.recognizedContent, image: image, historyState: HistoryState.shared) {
                    showPreviewWindow(contentView: PreviewContentView())
                }.recognizeBarcodes()
            } else {
                printOS("Failed to capture image")
            }
        }
    }

}
