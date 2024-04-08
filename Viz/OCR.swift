//
//  OCR.swift
//  Grabber
//
//  Created by Alin Lupascu on 4/5/24.
//

import SwiftUI
import Vision
import Foundation


struct TextRecognition {
//    @ObservedObject var recognizedContent: RecognizedContent
    var recognizedContent: RecognizedContent
    @AppStorage("appendRecognizedText") var appendRecognizedText: Bool = false

    var image: NSImage
    var didFinishRecognition: () -> Void

    func recognizeText() {
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        let requestHandler = VNImageRequestHandler(cgImage: cgImage!, options: [:])
        let textItem = TextItem()

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([self.getTextRecognitionRequest(with: textItem)])

                playSound(named: "printscreen")

                DispatchQueue.main.async {
                    self.updateRecognizedContent(with: textItem)
                    self.didFinishRecognition()
                    copyTextItemsToClipboard(textItems: self.recognizedContent.items)
                }
            } catch {
                print("Failed to recognize text: \(error.localizedDescription)")
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

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        return request
    }

    func recognizeBarcodes() {
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        let requestHandler = VNImageRequestHandler(cgImage: cgImage!, options: [:])
        let barcodeItem = TextItem()

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([self.getBarcodeRecognitionRequest(with: barcodeItem)])

                playSound(named: "printscreen")

                DispatchQueue.main.async {
                    self.updateRecognizedContent(with: barcodeItem)
                    self.didFinishRecognition()
                    copyTextItemsToClipboard(textItems: self.recognizedContent.items)
                }
            } catch {
                print("Failed to recognize barcodes: \(error.localizedDescription)")
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

    

    private func updateRecognizedContent(with textItem: TextItem) {
        if appendRecognizedText {
            recognizedContent.items.append(textItem)
        } else {
            recognizedContent.items = [textItem]
        }
    }

}





class CaptureService {
    static let shared = CaptureService()
    var screenCaptureUtility = ScreenCaptureUtility()
    var recognizedContent = RecognizedContent()
    let pasteboard = NSPasteboard.general

    func captureText() {
        screenCaptureUtility.captureScreenSelectionToClipboard { capturedImage in
            if let image = capturedImage {
                TextRecognition(recognizedContent: self.recognizedContent, image: image) {
                    previewWindow?.orderOut(nil)
                    previewWindow = nil
                    showPreview(content: self.recognizedContent)
                }.recognizeText()
            } else {
                print("Failed to capture image")
            }
        }
    }

    func captureBarcodes() {
        screenCaptureUtility.captureScreenSelectionToClipboard { capturedImage in
            if let image = capturedImage {
                TextRecognition(recognizedContent: self.recognizedContent, image: image) {
                    previewWindow?.orderOut(nil)
                    previewWindow = nil
                    showPreview(content: self.recognizedContent)
                }.recognizeBarcodes()
            } else {
                print("Failed to capture image")
            }
        }
    }

}
