import SwiftUI

struct HealthScoreView: View {
    let biomarkers: [Biomarker]

    private var score: Int {
        guard !biomarkers.isEmpty else { return 0 }
        let total = biomarkers.count
        let optimalCount = biomarkers.filter { $0.status == .optimal }.count
        let normalCount = biomarkers.filter { $0.status == .normal }.count
        let slightlyOffCount = biomarkers.filter { $0.status == .low || $0.status == .high }.count
        let criticalCount = biomarkers.filter { $0.status == .criticalLow || $0.status == .criticalHigh }.count

        let weighted = (optimalCount * 100 + normalCount * 75 + slightlyOffCount * 40 + criticalCount * 10)
        return min(100, weighted / total)
    }

    private var scoreColor: Color {
        if score >= 80 { return .green }
        if score >= 60 { return .blue }
        if score >= 40 { return .orange }
        return .red }
    private var scoreMessage: String {
        if score >= 80 { return "Most markers within standard ranges." }
        if score >= 60 { return "Some markers outside standard ranges." }
        if score >= 40 { return "Several markers outside standard ranges." }
        return "Many markers outside standard ranges. Review with your healthcare provider."
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut, value: score)
                Text("\(score)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(scoreColor)
            }
            .frame(width: 120, height: 120)

            Text("Overview")
                .font(.headline)
            Text(scoreMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 4) {
                Image(systemName: "info.circle")
                    .font(.caption2)
                Text("This is a data visualization tool, not a medical device.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.top, 2)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}
