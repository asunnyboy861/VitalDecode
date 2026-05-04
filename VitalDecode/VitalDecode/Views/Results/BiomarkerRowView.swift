import SwiftUI

struct BiomarkerRowView: View {
    let biomarker: Biomarker

    private var statusColor: Color {
        switch biomarker.status {
        case .criticalLow, .criticalHigh: return .red
        case .low, .high: return .orange
        case .normal: return .blue
        case .optimal: return .green
        }
    }

    private var statusIcon: String {
        switch biomarker.status {
        case .criticalLow: return "arrow.down.circle.fill"
        case .criticalHigh: return "arrow.up.circle.fill"
        case .low: return "arrow.down.right.circle.fill"
        case .high: return "arrow.up.right.circle.fill"
        case .normal: return "checkmark.circle.fill"
        case .optimal: return "star.fill"
        }
    }

    private var positionInOptimalRange: CGFloat {
        let range = biomarker.referenceHigh - biomarker.referenceLow
        guard range > 0 else { return 0.5 }
        let position = (biomarker.value - biomarker.referenceLow) / range
        return CGFloat(max(0, min(1, position)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: statusIcon)
                    .foregroundStyle(statusColor)
                    .font(.title3)
                VStack(alignment: .leading) {
                    Text(biomarker.canonicalName)
                        .font(.subheadline)
                        .bold()
                    Text(biomarker.category.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(biomarker.value, specifier: "%.1f")")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(statusColor)
                    Text(biomarker.unit)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            RangeBarView(
                value: biomarker.value,
                refLow: biomarker.referenceLow,
                refHigh: biomarker.referenceHigh,
                optLow: biomarker.optimalLow,
                optHigh: biomarker.optimalHigh,
                statusColor: statusColor
            )

            HStack {
                Text("Ref: \(biomarker.referenceLow, specifier: "%.1f") - \(biomarker.referenceHigh, specifier: "%.1f")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Optimal: \(biomarker.optimalLow, specifier: "%.1f") - \(biomarker.optimalHigh, specifier: "%.1f")")
                    .font(.caption2)
                    .foregroundStyle(.green.opacity(0.8))
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.03), radius: 3, y: 1)
    }
}
