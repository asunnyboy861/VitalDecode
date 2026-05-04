import Foundation
import PDFKit

struct ExportService {

    static func exportPDF(report: BloodTestReport) -> Data? {
        let pdfMetaData = [
            kCGPDFContextTitle: "VitalDecode Blood Test Report",
            kCGPDFContextCreator: "VitalDecode App"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            context.beginPage()

            var y: CGFloat = 50

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor(red: 0/255, green: 180/255, blue: 216/255, alpha: 1)
            ]
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.darkGray
            ]
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]

            "VitalDecode Blood Test Report".draw(at: CGPoint(x: 50, y: y), withAttributes: titleAttributes)
            y += 40

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let dateStr = "Date: \(dateFormatter.string(from: report.scanDate))"
            dateStr.draw(at: CGPoint(x: 50, y: y), withAttributes: bodyAttributes)
            y += 20

            if !report.labName.isEmpty {
                "Lab: \(report.labName)".draw(at: CGPoint(x: 50, y: y), withAttributes: bodyAttributes)
                y += 20
            }

            y += 10
            let sortedBiomarkers = report.biomarkers.sorted { $0.category.rawValue < $1.category.rawValue }
            var currentCategory = ""

            for biomarker in sortedBiomarkers {
                if biomarker.category.rawValue != currentCategory {
                    currentCategory = biomarker.category.rawValue
                    y += 15
                    currentCategory.draw(at: CGPoint(x: 50, y: y), withAttributes: headerAttributes)
                    y += 22
                }

                let statusIcon: String
                switch biomarker.status {
                case .criticalLow, .criticalHigh: statusIcon = "CRITICAL"
                case .low, .high: statusIcon = "OFF"
                case .normal: statusIcon = "NORMAL"
                case .optimal: statusIcon = "OPTIMAL"
                }

                let line = "\(biomarker.canonicalName): \(biomarker.value) \(biomarker.unit)  [\(statusIcon)]  Ref: \(biomarker.referenceLow)-\(biomarker.referenceHigh)  Optimal: \(biomarker.optimalLow)-\(biomarker.optimalHigh)"
                line.draw(at: CGPoint(x: 60, y: y), withAttributes: bodyAttributes)
                y += 18

                if y > pageHeight - 50 {
                    context.beginPage()
                    y = 50
                }
            }

            y += 30
            let disclaimer = "DISCLAIMER: This report is for informational purposes only and does not constitute medical advice. Always consult a qualified healthcare professional for medical decisions."
            disclaimer.draw(at: CGPoint(x: 50, y: y), withAttributes: [
                .font: UIFont.italicSystemFont(ofSize: 10),
                .foregroundColor: UIColor.gray
            ])
        }

        return data
    }

    static func exportCSV(biomarkers: [Biomarker]) -> String {
        var csv = "Name,Value,Unit,Status,Reference Low,Reference High,Optimal Low,Optimal High,Category\n"
        for marker in biomarkers {
            csv += "\(marker.canonicalName),\(marker.value),\(marker.unit),\(marker.status.rawValue),\(marker.referenceLow),\(marker.referenceHigh),\(marker.optimalLow),\(marker.optimalHigh),\(marker.category.rawValue)\n"
        }
        return csv
    }
}
