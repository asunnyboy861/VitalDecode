import SwiftUI

struct HealthScoreView: View {
    let biomarkers: [Biomarker]

    private var totalBiomarkers: Int { biomarkers.count }
    private var inOptimalCount: Int { biomarkers.filter { $0.status == .optimal }.count }
    private var inNormalCount: Int { biomarkers.filter { $0.status == .normal }.count }
    private var slightlyOffCount: Int { biomarkers.filter { $0.status == .low || $0.status == .high }.count }
    private var outsideRangeCount: Int { biomarkers.filter { $0.status == .criticalLow || $0.status == .criticalHigh }.count }

    private var overallStatusColor: Color {
        if outsideRangeCount > 0 { return .orange }
        if slightlyOffCount > 0 { return .blue }
        return .green
    }
    private var overviewMessage: String {
        if totalBiomarkers == 0 { return "No data available." }
        if outsideRangeCount > 0 {
            return "\(outsideRangeCount) marker(s) outside reference range. \(slightlyOffCount) slightly outside. Please consult your healthcare provider."
        }
        if slightlyOffCount > 0 {
            return "\(inOptimalCount + inNormalCount) of \(totalBiomarkers) markers within reference range. \(slightlyOffCount) slightly outside optimal."
        }
        return "All \(totalBiomarkers) markers are within reference ranges. \(inOptimalCount) within optimal range."
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.title2)
                    .foregroundStyle(overallStatusColor)
                Text("Biomarker Overview")
                    .font(.headline)
                Spacer()
            }

            Text(overviewMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)

            HStack(spacing: 0) {
                if inOptimalCount > 0 {
                    overviewBarSegment(count: inOptimalCount, total: totalBiomarkers, color: .green, label: "Optimal")
                }
                if inNormalCount > 0 {
                    overviewBarSegment(count: inNormalCount, total: totalBiomarkers, color: .blue, label: "Standard")
                }
                if slightlyOffCount > 0 {
                    overviewBarSegment(count: slightlyOffCount, total: totalBiomarkers, color: .orange, label: "Slightly Off")
                }
                if outsideRangeCount > 0 {
                    overviewBarSegment(count: outsideRangeCount, total: totalBiomarkers, color: .red, label: "Outside Range")
                }
            }
            .frame(height: 28)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            HStack(spacing: 16) {
                legendItem(color: .green, label: "Optimal (\(inOptimalCount))")
                legendItem(color: .blue, label: "Standard (\(inNormalCount))")
                legendItem(color: .orange, label: "Slightly Off (\(slightlyOffCount))")
                legendItem(color: .red, label: "Outside Range (\(outsideRangeCount))")
            }
            .font(.caption2)

            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
                Text("This is a data reference tool, not a medical device. Consult a healthcare professional for medical interpretation.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 2)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }

    private func overviewBarSegment(count: Int, total: Int, color: Color, label: String) -> some View {
        let fraction = total > 0 ? CGFloat(count) / CGFloat(total) : 0
        return Rectangle()
            .fill(color)
            .frame(maxWidth: .infinity, minHeight: 28)
            .overlay {
                if fraction > 0.15 {
                    Text(label)
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.white)
                }
            }
            .relativeWidth(fraction)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
}

extension View {
    func relativeWidth(_ fraction: CGFloat) -> some View {
        GeometryReader { geo in
            self.frame(width: geo.size.width * fraction)
        }
    }
}
