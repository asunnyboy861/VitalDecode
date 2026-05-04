import SwiftUI
import SwiftData
import VisionKit
import UniformTypeIdentifiers

struct ScanView: View {
    @State private var showScanner = false
    @State private var showPDFPicker = false
    @State private var showManualEntry = false
    @State private var isProcessing = false
    @State private var errorMessage: String?
    @State private var showError = false

    @Environment(\.modelContext) private var modelContext
    let userProfile: UserProfile
    let storeManager: StoreManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "doc.text.viewfinder")
                    .font(.system(size: 64))
                    .foregroundStyle(Color(red: 0/255, green: 180/255, blue: 216/255))

                VStack(spacing: 8) {
                    Text("Scan Your Blood Test")
                        .font(.title2)
                        .bold()

                    Text("Take a photo or upload a PDF")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 16) {
                    Button {
                        showScanner = true
                    } label: {
                        Label("Scan with Camera", systemImage: "camera")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0/255, green: 180/255, blue: 216/255))

                    Button {
                        showPDFPicker = true
                    } label: {
                        Label("Upload PDF", systemImage: "doc.badge.plus")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.bordered)
                    .tint(Color(red: 0/255, green: 180/255, blue: 216/255))

                    NavigationLink {
                        ManualEntryView(userProfile: userProfile, storeManager: storeManager)
                    } label: {
                        Label("Enter Manually", systemImage: "pencil.and.list.clipboard")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.bordered)
                    .tint(Color(red: 0/255, green: 180/255, blue: 216/255))
                }
                .padding(.horizontal, 32)

                HStack(spacing: 4) {
                    Image(systemName: "lock.shield")
                        .font(.caption)
                    Text("Your data stays on device")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)

                Spacer()
            }
            .navigationTitle("VitalDecode")
            .sheet(isPresented: $showScanner) {
                DocumentScannerView { images in
                    Task { await processImages(images) }
                }
            }
            .fileImporter(isPresented: $showPDFPicker, allowedContentTypes: [.pdf]) { result in
                Task { await processPDF(result) }
            }
            .overlay {
                if isProcessing {
                    ProgressView("Processing...")
                        .padding(32)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
        }
    }

    private func processImages(_ images: [UIImage]) async {
        isProcessing = true
        defer { isProcessing = false }

        let ocrService = OCRService()
        var allText = ""
        var allExtracted: [OCRService.ExtractedBiomarker] = []
        var totalConf: Float = 0

        for image in images {
            do {
                let result = try await ocrService.scanImage(image)
                allText += result.fullText + "\n"
                allExtracted.append(contentsOf: result.structuredData)
                totalConf += result.confidence
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                return
            }
        }

        let avgConf = images.isEmpty ? 0 : totalConf / Float(images.count)
        saveReport(rawText: allText, extracted: allExtracted, confidence: avgConf, source: .camera)
    }

    private func processPDF(_ result: Result<URL, Error>) async {
        isProcessing = true
        defer { isProcessing = false }

        switch result {
        case .success(let url):
            let ocrService = OCRService()
            do {
                let scanResult = try await ocrService.scanPDF(url: url)
                saveReport(rawText: scanResult.fullText, extracted: scanResult.structuredData, confidence: scanResult.confidence, source: .pdf)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func saveReport(rawText: String, extracted: [OCRService.ExtractedBiomarker], confidence: Float, source: BloodTestReport.SourceType) {
        let report = BloodTestReport(
            sourceType: source,
            rawOCRText: rawText,
            ocrConfidence: confidence
        )

        for extractedMarker in extracted {
            guard let definition = BiomarkerDefinitions.find(matching: extractedMarker.name) else { continue }
            guard let value = Double(extractedMarker.value) else { continue }

            let status = BiomarkerDefinitions.calculateStatus(
                value: value,
                refLow: definition.referenceLow,
                refHigh: definition.referenceHigh,
                optLow: definition.optimalLow,
                optHigh: definition.optimalHigh
            )

            let biomarker = Biomarker(
                name: extractedMarker.name,
                canonicalName: definition.canonicalName,
                value: value,
                unit: definition.unit,
                referenceLow: definition.referenceLow,
                referenceHigh: definition.referenceHigh,
                optimalLow: definition.optimalLow,
                optimalHigh: definition.optimalHigh,
                status: status,
                category: definition.category
            )
            biomarker.report = report
            report.biomarkers.append(biomarker)
        }

        modelContext.insert(report)
        if !storeManager.isPro {
            userProfile.incrementFreeScan()
        }
    }
}
