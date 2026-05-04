import Vision
import UIKit
import PDFKit

actor OCRService {

    struct OCRResult {
        let fullText: String
        let structuredData: [ExtractedBiomarker]
        let confidence: Float
    }

    struct ExtractedBiomarker {
        let name: String
        let value: String
        let unit: String
        let referenceRange: String?
        let confidence: Float
    }

    enum OCRError: Error {
        case invalidImage
        case recognitionFailed(String)
        case noTextFound
        case pdfExtractionFailed
    }

    func scanImage(_ image: UIImage) async throws -> OCRResult {
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }
        let text = try await performTextRecognition(on: cgImage)
        guard !text.isEmpty else {
            throw OCRError.noTextFound
        }
        let structured = BiomarkerParser.parse(from: text)
        let avgConfidence = structured.isEmpty ? 0.7 :
            structured.map(\.confidence).reduce(0, +) / Float(structured.count)
        return OCRResult(
            fullText: text,
            structuredData: structured,
            confidence: avgConfidence
        )
    }

    func scanPDF(url: URL) async throws -> OCRResult {
        guard let pdfDocument = PDFDocument(url: url) else {
            throw OCRError.pdfExtractionFailed
        }
        var allText = ""
        var allBiomarkers: [ExtractedBiomarker] = []
        var totalConfidence: Float = 0
        var pageCount = 0

        for pageIndex in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else { continue }
            let pageText = page.string ?? ""
            if !pageText.isEmpty {
                allText += pageText + "\n"
                let biomarkers = BiomarkerParser.parse(from: pageText)
                allBiomarkers.append(contentsOf: biomarkers)
                totalConfidence += biomarkers.isEmpty ? 0.7 :
                    biomarkers.map(\.confidence).reduce(0, +) / Float(max(biomarkers.count, 1))
                pageCount += 1
            } else {
                let pageRect = page.bounds(for: .mediaBox)
                let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                let pageImage = renderer.image { ctx in
                    UIColor.white.set()
                    ctx.fill(pageRect)
                    ctx.cgContext.translateBy(x: 0, y: pageRect.size.height)
                    ctx.cgContext.scaleBy(x: 1, y: -1)
                    page.draw(with: .mediaBox, to: ctx.cgContext)
                }
                let result = try await scanImage(pageImage)
                allText += result.fullText + "\n"
                allBiomarkers.append(contentsOf: result.structuredData)
                totalConfidence += result.confidence
                pageCount += 1
            }
        }
        guard !allText.isEmpty else {
            throw OCRError.noTextFound
        }
        return OCRResult(
            fullText: allText,
            structuredData: allBiomarkers,
            confidence: pageCount > 0 ? totalConfidence / Float(pageCount) : 0
        )
    }

    private func performTextRecognition(on cgImage: CGImage) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: OCRError.recognitionFailed(error.localizedDescription))
                    return
                }
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: OCRError.noTextFound)
                    return
                }
                let text = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")
                continuation.resume(returning: text)
            }
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US"]
            request.usesLanguageCorrection = true
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: OCRError.recognitionFailed(error.localizedDescription))
            }
        }
    }
}
