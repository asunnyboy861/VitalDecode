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

                let grouped = Dictionary(grouping: report.biomarkers) { $0.status }
                let needsAttention = (grouped[.criticalHigh] ?? []) + (grouped[.criticalLow] ?? [])
                let slightlyOff = (grouped[.high] ?? []) + (grouped[.low] ?? [])
                let normal = grouped[.normal] ?? []
                let optimal = grouped[.optimal] ?? []

                if !needsAttention.isEmpty {
                    CategoryHeader(title: "Needs Attention", color: .red, icon: "exclamationmark.triangle.fill")
                    ForEach(needsAttention) { biomarker in
                        BiomarkerRowView(biomarker: biomarker)
                    }
                }

                if !slightlyOff.isEmpty {
                    CategoryHeader(title: "Slightly Off", color: .orange, icon: "bolt.fill")
                    ForEach(slightlyOff) { biomarker in
                        BiomarkerRowView(biomarker: biomarker)
                    }
                }

                if !normal.isEmpty {
                    CategoryHeader(title: "In Standard Range", color: .blue, icon: "checkmark.circle.fill")
                    ForEach(normal) { biomarker in
                        BiomarkerRowView(biomarker: biomarker)
                    }
                }

                if !optimal.isEmpty {
                    CategoryHeader(title: "At Optimal Level", color: .green, icon: "star.fill")
                    ForEach(optimal) { biomarker in
                        BiomarkerRowView(biomarker: biomarker)
                    }
                }
            }
            .padding()
        }
    }
}
