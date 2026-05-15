import SwiftUI
import SwiftData

struct ResultsView: View {
    @Query(sort: \BloodTestReport.scanDate, order: .reverse) private var reports: [BloodTestReport]
    @State private var selectedReport: BloodTestReport?

    var body: some View {
        NavigationStack {
            Group {
                if let report = selectedReport ?? reports.first {
                    reportDetail(report)
                } else {
                    ContentUnavailableView(
                        "No Reports Yet",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("Scan your first blood test to see results here")
                    )
                }
            }
            .navigationTitle("Results")
            .toolbar {
                if reports.count > 1 {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            ForEach(reports) { report in
                                Button {
                                    selectedReport = report
                                } label: {
                                    Label(
                                        report.scanDate.formatted(date: .abbreviated, time: .shortened),
                                        systemImage: "doc.text"
                                    )
                                }
                            }
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                        }
                    }
                }
            }
        }
    }

    private func reportDetail(_ report: BloodTestReport) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                HealthScoreView(biomarkers: report.biomarkers)

                HStack(spacing: 6) {
                    Image(systemName: "heart.text.square")
                        .foregroundStyle(.red)
                    Text("Results analyzed by VitalDecode. Connect Apple Health in Settings for integrated health tracking.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 4)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("VitalDecode is a data reference tool and does not provide medical diagnosis or treatment advice.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "person.badge.shield.checkmark")
                            .foregroundStyle(.blue)
                        Text("Always seek a doctor's advice in addition to using this app and before making any medical decisions.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                let grouped = Dictionary(grouping: report.biomarkers) { $0.status }
                let needsAttention = (grouped[.criticalHigh] ?? []) + (grouped[.criticalLow] ?? [])
                let slightlyOff = (grouped[.high] ?? []) + (grouped[.low] ?? [])
                let normal = grouped[.normal] ?? []
                let optimal = grouped[.optimal] ?? []

                if !needsAttention.isEmpty {
                    CategoryHeader(title: "Outside Reference Range", color: .red, icon: "exclamationmark.triangle.fill")
                    ForEach(needsAttention) { biomarker in
                        BiomarkerRowView(biomarker: biomarker)
                    }
                }

                if !slightlyOff.isEmpty {
                    CategoryHeader(title: "Slightly Outside Optimal Range", color: .orange, icon: "bolt.fill")
                    ForEach(slightlyOff) { biomarker in
                        BiomarkerRowView(biomarker: biomarker)
                    }
                }

                if !normal.isEmpty {
                    CategoryHeader(title: "Within Reference Range", color: .blue, icon: "checkmark.circle.fill")
                    ForEach(normal) { biomarker in
                        BiomarkerRowView(biomarker: biomarker)
                    }
                }

                if !optimal.isEmpty {
                    CategoryHeader(title: "Within Optimal Range", color: .green, icon: "star.fill")
                    ForEach(optimal) { biomarker in
                        BiomarkerRowView(biomarker: biomarker)
                    }
                }
            }
            .padding()
        }
    }
}
