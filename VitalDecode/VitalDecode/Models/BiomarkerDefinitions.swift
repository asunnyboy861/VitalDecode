import Foundation

struct BiomarkerDefinition: Identifiable {
    let id = UUID()
    let canonicalName: String
    let aliases: [String]
    let unit: String
    let referenceLow: Double
    let referenceHigh: Double
    let optimalLow: Double
    let optimalHigh: Double
    let category: Biomarker.BiomarkerCategory
}

struct BiomarkerDefinitions {
    static let all: [BiomarkerDefinition] = [
        BiomarkerDefinition(canonicalName: "WBC", aliases: ["White Blood Cell", "White Blood Cells", "Leukocyte", "WBC"], unit: "K/uL", referenceLow: 4.5, referenceHigh: 11.0, optimalLow: 5.0, optimalHigh: 8.0, category: .completeBloodCount),
        BiomarkerDefinition(canonicalName: "RBC", aliases: ["Red Blood Cell", "Red Blood Cells", "Erythrocyte", "RBC"], unit: "M/uL", referenceLow: 4.5, referenceHigh: 5.5, optimalLow: 4.7, optimalHigh: 5.2, category: .completeBloodCount),
        BiomarkerDefinition(canonicalName: "Hemoglobin", aliases: ["Hemoglobin", "Hgb", "Hb"], unit: "g/dL", referenceLow: 13.5, referenceHigh: 17.5, optimalLow: 14.0, optimalHigh: 16.0, category: .completeBloodCount),
        BiomarkerDefinition(canonicalName: "Hematocrit", aliases: ["Hematocrit", "Hct"], unit: "%", referenceLow: 41, referenceHigh: 50, optimalLow: 43, optimalHigh: 48, category: .completeBloodCount),
        BiomarkerDefinition(canonicalName: "MCV", aliases: ["Mean Corpuscular Volume", "MCV"], unit: "fL", referenceLow: 80, referenceHigh: 100, optimalLow: 85, optimalHigh: 95, category: .completeBloodCount),
        BiomarkerDefinition(canonicalName: "MCH", aliases: ["Mean Corpuscular Hemoglobin", "MCH"], unit: "pg", referenceLow: 27, referenceHigh: 33, optimalLow: 28, optimalHigh: 32, category: .completeBloodCount),
        BiomarkerDefinition(canonicalName: "MCHC", aliases: ["Mean Corpuscular Hemoglobin Concentration", "MCHC"], unit: "g/dL", referenceLow: 32, referenceHigh: 36, optimalLow: 33, optimalHigh: 35, category: .completeBloodCount),
        BiomarkerDefinition(canonicalName: "Platelets", aliases: ["Platelet", "Platelets", "PLT"], unit: "K/uL", referenceLow: 150, referenceHigh: 400, optimalLow: 180, optimalHigh: 350, category: .completeBloodCount),
        BiomarkerDefinition(canonicalName: "Neutrophils", aliases: ["Neutrophil", "Neutrophils", "NEUT"], unit: "%", referenceLow: 40, referenceHigh: 70, optimalLow: 45, optimalHigh: 65, category: .completeBloodCount),
        BiomarkerDefinition(canonicalName: "Lymphocytes", aliases: ["Lymphocyte", "Lymphocytes", "LYMPH"], unit: "%", referenceLow: 20, referenceHigh: 40, optimalLow: 25, optimalHigh: 35, category: .completeBloodCount),
        BiomarkerDefinition(canonicalName: "Glucose", aliases: ["Glucose", "Fasting Glucose", "Blood Sugar", "FBG", "Fasting Blood Glucose"], unit: "mg/dL", referenceLow: 70, referenceHigh: 100, optimalLow: 75, optimalHigh: 88, category: .metabolicPanel),
        BiomarkerDefinition(canonicalName: "HbA1c", aliases: ["Hemoglobin A1c", "HbA1c", "A1C", "Glycated Hemoglobin"], unit: "%", referenceLow: 4.0, referenceHigh: 5.6, optimalLow: 4.5, optimalHigh: 5.2, category: .metabolicPanel),
        BiomarkerDefinition(canonicalName: "BUN", aliases: ["Blood Urea Nitrogen", "BUN", "Urea Nitrogen"], unit: "mg/dL", referenceLow: 7, referenceHigh: 20, optimalLow: 10, optimalHigh: 18, category: .metabolicPanel),
        BiomarkerDefinition(canonicalName: "Creatinine", aliases: ["Creatinine", "Cr", "Serum Creatinine"], unit: "mg/dL", referenceLow: 0.7, referenceHigh: 1.3, optimalLow: 0.8, optimalHigh: 1.1, category: .metabolicPanel),
        BiomarkerDefinition(canonicalName: "eGFR", aliases: ["Estimated GFR", "eGFR", "Glomerular Filtration Rate"], unit: "mL/min", referenceLow: 60, referenceHigh: 120, optimalLow: 90, optimalHigh: 120, category: .kidney),
        BiomarkerDefinition(canonicalName: "Sodium", aliases: ["Sodium", "Na", "Na+"], unit: "mEq/L", referenceLow: 136, referenceHigh: 145, optimalLow: 138, optimalHigh: 143, category: .metabolicPanel),
        BiomarkerDefinition(canonicalName: "Potassium", aliases: ["Potassium", "K", "K+"], unit: "mEq/L", referenceLow: 3.5, referenceHigh: 5.0, optimalLow: 3.8, optimalHigh: 4.5, category: .metabolicPanel),
        BiomarkerDefinition(canonicalName: "Chloride", aliases: ["Chloride", "Cl", "Cl-"], unit: "mEq/L", referenceLow: 98, referenceHigh: 106, optimalLow: 100, optimalHigh: 104, category: .metabolicPanel),
        BiomarkerDefinition(canonicalName: "CO2", aliases: ["Carbon Dioxide", "CO2", "Bicarbonate", "HCO3"], unit: "mEq/L", referenceLow: 23, referenceHigh: 29, optimalLow: 24, optimalHigh: 28, category: .metabolicPanel),
        BiomarkerDefinition(canonicalName: "Calcium", aliases: ["Calcium", "Ca", "Serum Calcium"], unit: "mg/dL", referenceLow: 8.5, referenceHigh: 10.5, optimalLow: 9.0, optimalHigh: 10.0, category: .metabolicPanel),
        BiomarkerDefinition(canonicalName: "Total Cholesterol", aliases: ["Total Cholesterol", "Cholesterol", "TC"], unit: "mg/dL", referenceLow: 0, referenceHigh: 200, optimalLow: 150, optimalHigh: 199, category: .lipidPanel),
        BiomarkerDefinition(canonicalName: "LDL Cholesterol", aliases: ["LDL", "LDL Cholesterol", "Low Density Lipoprotein", "LDL-C"], unit: "mg/dL", referenceLow: 0, referenceHigh: 100, optimalLow: 50, optimalHigh: 80, category: .lipidPanel),
        BiomarkerDefinition(canonicalName: "HDL Cholesterol", aliases: ["HDL", "HDL Cholesterol", "High Density Lipoprotein", "HDL-C"], unit: "mg/dL", referenceLow: 40, referenceHigh: 80, optimalLow: 55, optimalHigh: 80, category: .lipidPanel),
        BiomarkerDefinition(canonicalName: "Triglycerides", aliases: ["Triglycerides", "TG", "Triglyceride"], unit: "mg/dL", referenceLow: 0, referenceHigh: 150, optimalLow: 50, optimalHigh: 100, category: .lipidPanel),
        BiomarkerDefinition(canonicalName: "VLDL", aliases: ["VLDL", "Very Low Density Lipoprotein"], unit: "mg/dL", referenceLow: 2, referenceHigh: 30, optimalLow: 5, optimalHigh: 20, category: .lipidPanel),
        BiomarkerDefinition(canonicalName: "TSH", aliases: ["Thyroid Stimulating Hormone", "TSH"], unit: "mIU/L", referenceLow: 0.4, referenceHigh: 4.0, optimalLow: 1.0, optimalHigh: 2.5, category: .thyroid),
        BiomarkerDefinition(canonicalName: "Free T4", aliases: ["Free T4", "FT4", "Thyroxine Free"], unit: "ng/dL", referenceLow: 0.8, referenceHigh: 1.8, optimalLow: 1.0, optimalHigh: 1.5, category: .thyroid),
        BiomarkerDefinition(canonicalName: "Free T3", aliases: ["Free T3", "FT3", "Triiodothyronine Free"], unit: "pg/mL", referenceLow: 2.3, referenceHigh: 4.2, optimalLow: 2.8, optimalHigh: 3.8, category: .thyroid),
        BiomarkerDefinition(canonicalName: "Vitamin D", aliases: ["Vitamin D", "25-OH Vitamin D", "25-Hydroxyvitamin D", "25(OH)D"], unit: "ng/mL", referenceLow: 30, referenceHigh: 100, optimalLow: 40, optimalHigh: 70, category: .vitamins),
        BiomarkerDefinition(canonicalName: "Vitamin B12", aliases: ["Vitamin B12", "Cobalamin", "B12"], unit: "pg/mL", referenceLow: 200, referenceHigh: 900, optimalLow: 400, optimalHigh: 700, category: .vitamins),
        BiomarkerDefinition(canonicalName: "Folate", aliases: ["Folate", "Folic Acid", "Vitamin B9"], unit: "ng/mL", referenceLow: 3, referenceHigh: 20, optimalLow: 10, optimalHigh: 20, category: .vitamins),
        BiomarkerDefinition(canonicalName: "Iron", aliases: ["Iron", "Serum Iron", "Fe"], unit: "ug/dL", referenceLow: 60, referenceHigh: 170, optimalLow: 80, optimalHigh: 140, category: .iron),
        BiomarkerDefinition(canonicalName: "Ferritin", aliases: ["Ferritin"], unit: "ng/mL", referenceLow: 12, referenceHigh: 300, optimalLow: 50, optimalHigh: 150, category: .iron),
        BiomarkerDefinition(canonicalName: "TIBC", aliases: ["Total Iron Binding Capacity", "TIBC"], unit: "ug/dL", referenceLow: 250, referenceHigh: 370, optimalLow: 280, optimalHigh: 350, category: .iron),
        BiomarkerDefinition(canonicalName: "ALT", aliases: ["Alanine Aminotransferase", "ALT", "SGPT"], unit: "U/L", referenceLow: 7, referenceHigh: 56, optimalLow: 10, optimalHigh: 30, category: .liver),
        BiomarkerDefinition(canonicalName: "AST", aliases: ["Aspartate Aminotransferase", "AST", "SGOT"], unit: "U/L", referenceLow: 10, referenceHigh: 40, optimalLow: 12, optimalHigh: 25, category: .liver),
        BiomarkerDefinition(canonicalName: "ALP", aliases: ["Alkaline Phosphatase", "ALP"], unit: "U/L", referenceLow: 44, referenceHigh: 147, optimalLow: 50, optimalHigh: 100, category: .liver),
        BiomarkerDefinition(canonicalName: "GGT", aliases: ["Gamma-Glutamyl Transferase", "GGT", "Gamma GT"], unit: "U/L", referenceLow: 9, referenceHigh: 48, optimalLow: 10, optimalHigh: 30, category: .liver),
        BiomarkerDefinition(canonicalName: "Bilirubin Total", aliases: ["Total Bilirubin", "Bilirubin", "TBIL"], unit: "mg/dL", referenceLow: 0.1, referenceHigh: 1.2, optimalLow: 0.2, optimalHigh: 0.8, category: .liver),
        BiomarkerDefinition(canonicalName: "Albumin", aliases: ["Albumin", "ALB"], unit: "g/dL", referenceLow: 3.5, referenceHigh: 5.5, optimalLow: 4.0, optimalHigh: 5.0, category: .liver),
        BiomarkerDefinition(canonicalName: "Total Protein", aliases: ["Total Protein", "TP"], unit: "g/dL", referenceLow: 6.0, referenceHigh: 8.3, optimalLow: 6.5, optimalHigh: 7.5, category: .liver),
        BiomarkerDefinition(canonicalName: "CRP", aliases: ["C-Reactive Protein", "CRP", "hs-CRP", "High Sensitivity CRP"], unit: "mg/L", referenceLow: 0, referenceHigh: 3.0, optimalLow: 0, optimalHigh: 1.0, category: .inflammation),
        BiomarkerDefinition(canonicalName: "ESR", aliases: ["Erythrocyte Sedimentation Rate", "ESR", "Sed Rate"], unit: "mm/hr", referenceLow: 0, referenceHigh: 20, optimalLow: 0, optimalHigh: 10, category: .inflammation),
        BiomarkerDefinition(canonicalName: "Uric Acid", aliases: ["Uric Acid", "UA"], unit: "mg/dL", referenceLow: 3.5, referenceHigh: 7.2, optimalLow: 4.0, optimalHigh: 6.0, category: .metabolicPanel),
        BiomarkerDefinition(canonicalName: "Testosterone", aliases: ["Testosterone", "Total Testosterone"], unit: "ng/dL", referenceLow: 264, referenceHigh: 916, optimalLow: 500, optimalHigh: 800, category: .hormones),
        BiomarkerDefinition(canonicalName: "Cortisol", aliases: ["Cortisol", "Serum Cortisol"], unit: "ug/dL", referenceLow: 6.2, referenceHigh: 19.4, optimalLow: 8.0, optimalHigh: 15.0, category: .hormones),
        BiomarkerDefinition(canonicalName: "DHEA-S", aliases: ["DHEA-S", "Dehydroepiandrosterone Sulfate"], unit: "ug/dL", referenceLow: 98, referenceHigh: 340, optimalLow: 150, optimalHigh: 300, category: .hormones),
        BiomarkerDefinition(canonicalName: "TSH", aliases: ["TSH"], unit: "mIU/L", referenceLow: 0.4, referenceHigh: 4.0, optimalLow: 1.0, optimalHigh: 2.5, category: .thyroid),
        BiomarkerDefinition(canonicalName: "Magnesium", aliases: ["Magnesium", "Mg"], unit: "mg/dL", referenceLow: 1.7, referenceHigh: 2.2, optimalLow: 1.8, optimalHigh: 2.1, category: .metabolicPanel),
        BiomarkerDefinition(canonicalName: "Phosphorus", aliases: ["Phosphorus", "Phosphate", "P"], unit: "mg/dL", referenceLow: 2.5, referenceHigh: 4.5, optimalLow: 3.0, optimalHigh: 4.0, category: .metabolicPanel),
    ]

    static func find(matching name: String) -> BiomarkerDefinition? {
        let lowerName = name.lowercased().trimmingCharacters(in: .whitespaces)
        return all.first { def in
            def.canonicalName.lowercased() == lowerName ||
            def.aliases.contains { $0.lowercased() == lowerName }
        }
    }

    static func calculateStatus(value: Double, refLow: Double, refHigh: Double, optLow: Double, optHigh: Double) -> Biomarker.BiomarkerStatus {
        let criticalMargin = (refHigh - refLow) * 0.25
        if value < refLow - criticalMargin { return .criticalLow }
        if value < optLow { return .low }
        if value >= optLow && value <= optHigh { return .optimal }
        if value >= refLow && value <= refHigh { return .normal }
        if value > refHigh + criticalMargin { return .criticalHigh }
        return .high
    }
}
