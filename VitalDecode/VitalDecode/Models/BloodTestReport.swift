import SwiftData
import Foundation

@Model
final class BloodTestReport {
    @Attribute(.unique) var id: UUID
    var scanDate: Date
    var labName: String
    var sourceType: SourceType
    var rawOCRText: String
    var ocrConfidence: Float
    @Relationship(deleteRule: .cascade, inverse: \Biomarker.report) var biomarkers: [Biomarker]
    var aiAnalysisJSON: Data?
    var notes: String

    enum SourceType: String, Codable {
        case camera
        case pdf
        case manual
        case healthKit
    }

    init(
        scanDate: Date = .now,
        labName: String = "",
        sourceType: SourceType = .camera,
        rawOCRText: String = "",
        ocrConfidence: Float = 0
    ) {
        self.id = UUID()
        self.scanDate = scanDate
        self.labName = labName
        self.sourceType = sourceType
        self.rawOCRText = rawOCRText
        self.ocrConfidence = ocrConfidence
        self.biomarkers = []
        self.notes = ""
    }
}
