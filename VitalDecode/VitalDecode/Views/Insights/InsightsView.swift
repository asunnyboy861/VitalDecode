import SwiftUI
import SwiftData

struct InsightsView: View {
    @Query(sort: \BloodTestReport.scanDate, order: .reverse) private var reports: [BloodTestReport]
    @State private var analysis: AIAnalysisService.AIAnalysis?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showPaywall = false
    @State private var refreshTrigger = false

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
                handleAnalyzeButtonTap()
            } label: {
                Label("Analyze My Results", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0/255, green: 180/255, blue: 216/255))
            .padding(.horizontal)
        }
        .sheet(isPresented: $showPaywall, onDismiss: {
            // Refresh subscription status when paywall is dismissed
            Task { await storeManager.refreshSubscriptionStatus() }
            // If user is now Pro and no analysis yet, auto-run analysis
            if storeManager.isPro && analysis == nil && !isLoading {
                Task { await runAnalysis() }
            }
        }) {
            PaywallView(storeManager: storeManager)
        }
    }

    private func handleAnalyzeButtonTap() {
        // First refresh subscription status to ensure we have latest data
        Task {
            await storeManager.refreshSubscriptionStatus()

            // Small delay to ensure state is updated
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second

            if storeManager.isPro {
                await runAnalysis()
            } else {
                showPaywall = true
            }
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
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func runAnalysis() async {
        guard let report = latestReport else { return }

        isLoading = true
        errorMessage = nil

        do {
            let service = AIAnalysisService()
            analysis = try await service.analyze(biomarkers: report.biomarkers, userProfile: userProfile)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

struct InsightSection: View {
    let icon: String
    let title: String
    let color: Color
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundStyle(color)
                            .padding(.top, 6)
                        Text(item)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
