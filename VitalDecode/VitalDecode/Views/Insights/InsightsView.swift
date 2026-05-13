import SwiftUI
import SwiftData

struct InsightsView: View {
    @Query(sort: \BloodTestReport.scanDate, order: .reverse) private var reports: [BloodTestReport]
    @State private var currentAnalysis: AIAnalysisService.AIAnalysis?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showPaywall = false
    @State private var showAIConsent = false
    @State private var showNoAPIKeyAlert = false

    let userProfile: UserProfile
    let storeManager: StoreManager
    let aiConsentManager: AIConsentManager

    private var latestReport: BloodTestReport? { reports.first }

    private var hasAPIKey: Bool {
        !(UserDefaults.standard.string(forKey: "openai_api_key") ?? "").isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if reports.first != nil {
                    if currentAnalysis != nil {
                        analysisContentView
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
            .sheet(isPresented: $showAIConsent) {
                AIConsentView {
                    aiConsentManager.recordConsent()
                    proceedWithAnalysis()
                }
            }
            .alert("API Key Required", isPresented: $showNoAPIKeyAlert) {
                Button("OK") {}
            } message: {
                Text("To use AI analysis, please enter your OpenAI API key in Settings, or upgrade to Pro.")
            }
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
            Task { await storeManager.refreshSubscriptionStatus() }
            if storeManager.isPro && currentAnalysis == nil && !isLoading {
                Task { await runAnalysis() }
            }
        }) {
            PaywallView(storeManager: storeManager)
        }
    }

    private func handleAnalyzeButtonTap() {
        let canAnalyze = storeManager.isPro || hasAPIKey

        if !canAnalyze {
            showPaywall = true
            return
        }

        if !aiConsentManager.hasConsented {
            showAIConsent = true
            return
        }

        proceedWithAnalysis()
    }

    private func proceedWithAnalysis() {
        Task {
            await storeManager.refreshSubscriptionStatus()

            await MainActor.run {
                if storeManager.isPro || hasAPIKey {
                    Task { await runAnalysis() }
                } else {
                    showPaywall = true
                }
            }
        }
    }

    @ViewBuilder
    private var analysisContentView: some View {
        if let analysis = currentAnalysis {
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
            currentAnalysis = try await service.analyze(biomarkers: report.biomarkers, userProfile: userProfile)
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
