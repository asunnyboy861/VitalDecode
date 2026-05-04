import SwiftData
import Foundation

@Model
final class Biomarker {
    @Attribute(.unique) var id: UUID
    var name: String
    var canonicalName: String
    var value: Double
    var unit: String
    var referenceLow: Double
    var referenceHigh: Double
    var optimalLow: Double
    var optimalHigh: Double
    var status: BiomarkerStatus
    var category: BiomarkerCategory
    var report: BloodTestReport?

    enum BiomarkerStatus: String, Codable {
        case criticalLow
        case low
        case normal
        case optimal
        case high
        case criticalHigh
    }

    enum BiomarkerCategory: String, Codable, CaseIterable {
        case completeBloodCount = "CBC"
        case metabolicPanel = "Metabolic"
        case lipidPanel = "Lipid"
        case thyroid = "Thyroid"
        case hormones = "Hormones"
        case vitamins = "Vitamins"
        case iron = "Iron"
        case liver = "Liver"
        case kidney = "Kidney"
        case inflammation = "Inflammation"
        case other = "Other"
    }

    init(
        name: String,
        canonicalName: String,
        value: Double,
        unit: String,
        referenceLow: Double = 0,
        referenceHigh: Double = 0,
        optimalLow: Double = 0,
        optimalHigh: Double = 0,
        status: BiomarkerStatus = .normal,
        category: BiomarkerCategory = .other
    ) {
        self.id = UUID()
        self.name = name
        self.canonicalName = canonicalName
        self.value = value
        self.unit = unit
        self.referenceLow = referenceLow
        self.referenceHigh = referenceHigh
        self.optimalLow = optimalLow
        self.optimalHigh = optimalHigh
        self.status = status
        self.category = category
    }
}
