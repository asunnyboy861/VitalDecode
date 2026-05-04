import SwiftUI
import SwiftData

struct InsightsView: View {
    @Query(sort: \BloodTestReport.scanDate, order: .reverse) private var reports: [BloodTestReport]
    @State private var analysis: AIAnalysisService.AIAnalysis?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showPaywall = false

    let userProfile: UserProfile
    let storeManager: StoreManager

    private var latestReport: BloodTestReport? { reports.first }

    var body: some View {
        NavigationStack {
            Group {
                if reports.first != nil {
                    if let analysis {
                        analysisContent(analysis)
                    } else if isLoading {
                        ProgressView("Analyzing your results...")
                            .padding()
                    } else {
                        startAnalysisView
                    }
                } else {
                    ContentUnavailableView(
                        "No Reports Yet",
                        systemImage: "brain.head.profile",
                        description: Text("Scan a blood test first to get AI insights")
                    )
                }
            }
            .navigationTitle("AI Insights")
        }
    }

    private var startAnalysisView: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundStyle(Color(red: 0/255, green: 180/255, blue: 216/255))

            Text("Get AI-Powered Insights")
                .font(.title2)
                .bold()

            Text("Understand your blood test results in plain English with personalized recommendations.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                if storeManager.isPro {
                    Task { await runAnalysis() }
                } else {
                    showPaywall = true
                }
            } label: {
                Label("Analyze My Results", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0/255, green: 180/255, blue: 216/255))
            .padding(.horizontal)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(storeManager: storeManager)
        }
    }

    private func analysisContent(_ analysis: AIAnalysisService.AIAnalysis) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                InsightSection(icon: "text.bubble", title: "Summary", color: .blue, items: [analysis.summary])

                InsightSection(icon: "magnifyingglass", title: "Key Findings", color: .orange, items: analysis.keyFindings)

                InsightSection(icon: "link", title: "Correlations", color: .purple, items: analysis.correlations)

                InsightSection(icon: "lightbulb", title: "Recommendations", color: .green, items: analysis.recommendations)

                InsightSection(icon: "checkmark.circle", title: "Action Items", color: Color(red: 0/255, green: 180/255, blue: 216/255), items: analysis.actionItems)

                disclaimerView
            }
            .padding()
        }
    }

    private var disclaimerView: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(.orange)
            Text("This analysis is for informational purposes only and does not constitute medical advice. Always consult a qualified healthcare professional.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func runAnalysis() async {
        guard let report = latestReport else { return }
        isLoading = true
        defer { isLoading = false }

        let service = AIAnalysisService()
        do {
            analysis = try await service.analyze(biomarkers: report.biomarkers, userProfile: userProfile)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct InsightSection: View {
    let icon: String
    let title: String
    let color: Color
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.headline)
            }

            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .foregroundStyle(color)
                    Text(item)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.03), radius: 3, y: 1)
    }
}
