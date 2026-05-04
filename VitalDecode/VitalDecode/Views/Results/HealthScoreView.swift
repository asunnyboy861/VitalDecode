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
        if score >= 80 { return "Great results! A few areas to optimize." }
        if score >= 60 { return "Good overall, some areas to improve." }
        if score >= 40 { return "Several markers need attention." }
        return "Important: Discuss these results with your doctor."
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

            Text("Health Score")
                .font(.headline)
            Text(scoreMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}
