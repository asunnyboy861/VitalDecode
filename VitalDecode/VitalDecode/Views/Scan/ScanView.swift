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
                    Text("Scan Your Lab Report")
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

                    Button {
                        loadSampleReport()
                    } label: {
                        Label("Load Sample Report", systemImage: "doc.text.magnifyingglass")
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

                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        Text("This app is not intended to diagnose, treat, cure, or prevent any disease or medical condition.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Text("Users of this app must seek a doctor's advice in addition to using this app and before making any medical decisions.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)

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

    private func loadSampleReport() {
        let report = BloodTestReport(
            labName: "Sample Lab — Demo Report",
            sourceType: .manual,
            rawOCRText: "Sample Blood Test Report for demonstration purposes",
            ocrConfidence: 1.0
        )

        let sampleData: [(String, Double, Biomarker.BiomarkerCategory)] = [
            ("WBC", 6.2, .completeBloodCount),
            ("RBC", 4.8, .completeBloodCount),
            ("Hemoglobin", 14.5, .completeBloodCount),
            ("Hematocrit", 44, .completeBloodCount),
            ("MCV", 90, .completeBloodCount),
            ("Platelets", 250, .completeBloodCount),
            ("Glucose", 92, .metabolicPanel),
            ("HbA1c", 5.3, .metabolicPanel),
            ("BUN", 15, .metabolicPanel),
            ("Creatinine", 0.95, .metabolicPanel),
            ("eGFR", 105, .kidney),
            ("Sodium", 140, .metabolicPanel),
            ("Potassium", 4.1, .metabolicPanel),
            ("Calcium", 9.5, .metabolicPanel),
            ("Total Cholesterol", 185, .lipidPanel),
            ("LDL Cholesterol", 95, .lipidPanel),
            ("HDL Cholesterol", 62, .lipidPanel),
            ("Triglycerides", 110, .lipidPanel),
            ("ALT", 22, .liver),
            ("AST", 18, .liver),
            ("ALP", 75, .liver),
            ("Albumin", 4.5, .liver),
            ("Total Protein", 7.0, .liver),
            ("TSH", 2.1, .thyroid),
            ("Free T4", 1.2, .thyroid),
            ("Vitamin D", 28, .vitamins),
            ("Vitamin B12", 380, .vitamins),
            ("Iron", 75, .iron),
            ("Ferritin", 45, .iron),
            ("CRP", 1.5, .inflammation),
            ("Testosterone", 520, .hormones),
            ("Cortisol", 12.5, .hormones),
            ("DHEA-S", 210, .hormones),
        ]

        for (name, value, category) in sampleData {
            guard let definition = BiomarkerDefinitions.find(matching: name) else { continue }
            let status = BiomarkerDefinitions.calculateStatus(
                value: value,
                refLow: definition.referenceLow,
                refHigh: definition.referenceHigh,
                optLow: definition.optimalLow,
                optHigh: definition.optimalHigh
            )
            let biomarker = Biomarker(
                name: name,
                canonicalName: definition.canonicalName,
                value: value,
                unit: definition.unit,
                referenceLow: definition.referenceLow,
                referenceHigh: definition.referenceHigh,
                optimalLow: definition.optimalLow,
                optimalHigh: definition.optimalHigh,
                status: status,
                category: category
            )
            biomarker.report = report
            report.biomarkers.append(biomarker)
        }

        modelContext.insert(report)
    }
}
