import SwiftUI
import SwiftData
import Charts

struct TrendsView: View {
    @Query(sort: \BloodTestReport.scanDate) private var reports: [BloodTestReport]
    @State private var selectedBiomarker: String = ""
    @State private var showPaywall = false

    let storeManager: StoreManager

    private var allBiomarkerNames: [String] {
        let names = Set(reports.flatMap { $0.biomarkers.map(\.canonicalName) })
        return names.sorted()
    }

    private var trendData: [TrendPoint] {
        guard !selectedBiomarker.isEmpty else { return [] }
        var points: [TrendPoint] = []
        for report in reports {
            if let marker = report.biomarkers.first(where: { $0.canonicalName == selectedBiomarker }) {
                points.append(TrendPoint(
                    date: report.scanDate,
                    value: marker.value,
                    status: marker.status
                ))
            }
        }
        return points
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if allBiomarkerNames.isEmpty {
                    ContentUnavailableView(
                        "No Data Yet",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Scan blood tests to track trends over time")
                    )
                } else {
                    Picker("Biomarker", selection: $selectedBiomarker) {
                        Text("Select...").tag("")
                        ForEach(allBiomarkerNames, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    .pickerStyle(.menu)

                    if !trendData.isEmpty {
                        chartView
                    } else if !selectedBiomarker.isEmpty {
                        ContentUnavailableView(
                            "No Data",
                            systemImage: "chart.bar",
                            description: Text("No data for \(selectedBiomarker)")
                        )
                    }
                }
            }
            .padding()
            .navigationTitle("Trends")
            .onChange(of: allBiomarkerNames) { _, newNames in
                if selectedBiomarker.isEmpty && !newNames.isEmpty {
                    selectedBiomarker = newNames[0]
                }
            }
        }
    }

    private var chartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedBiomarker)
                .font(.headline)

            Chart(trendData) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(Color(red: 0/255, green: 180/255, blue: 216/255))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(point.statusColor)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }

            if let definition = BiomarkerDefinitions.find(matching: selectedBiomarker) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Reference Range")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(definition.referenceLow, specifier: "%.1f") - \(definition.referenceHigh, specifier: "%.1f") \(definition.unit)")
                            .font(.caption)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Optimal Range")
                            .font(.caption)
                            .foregroundStyle(.green)
                        Text("\(definition.optimalLow, specifier: "%.1f") - \(definition.optimalHigh, specifier: "%.1f") \(definition.unit)")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.03), radius: 3, y: 1)
    }
}

private struct TrendPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let status: Biomarker.BiomarkerStatus

    var statusColor: Color {
        switch status {
        case .criticalLow, .criticalHigh: return .red
        case .low, .high: return .orange
        case .normal: return .blue
        case .optimal: return .green
        }
    }
}
