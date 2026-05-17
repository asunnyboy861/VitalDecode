import SwiftUI
import SwiftData

struct InsightsView: View {
    @Query(sort: \BloodTestReport.scanDate, order: .reverse) private var reports: [BloodTestReport]
    @State private var currentAnalysis: AIAnalysisService.AIAnalysis?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showPaywall = false
    @State private var showAIConsent = false

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
                        loadingView
                    } else {
                        startAnalysisView
                    }
                } else {
                    ContentUnavailableView(
                        "No Reports Yet",
                        systemImage: "brain.head.profile",
                        description: Text("Scan a blood test first to get data comparison")
                    )
                }
            }
            .navigationTitle("Data Comparison")
        }
        .sheet(isPresented: $showAIConsent) {
            AIConsentView {
                aiConsentManager.recordConsent()
                runAnalysis()
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(storeManager: storeManager)
        }
        .alert("Analysis Error", isPresented: $showError) {
            Button("Try Built-in Analysis") {
                runFallbackAnalysis()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "An error occurred during analysis. You can use the built-in analysis instead.")
        }
        .onChange(of: showPaywall) { _, newValue in
            if !newValue {
                Task {
                    await storeManager.refreshSubscriptionStatus()
                }
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color(red: 0/255, green: 180/255, blue: 216/255))
            Text("Analyzing your results...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var startAnalysisView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 56))
                    .foregroundStyle(Color(red: 0/255, green: 180/255, blue: 216/255))

                Text("Get AI-Powered Data Comparison")
                    .font(.title2)
                    .bold()

                Text("Compare your blood test results to standard reference ranges and get topics to discuss with your healthcare provider.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Button(action: handleAnalyzeButtonTap) {
                    Label("Compare My Results", systemImage: "sparkles")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(Color(red: 0/255, green: 180/255, blue: 216/255))
                .padding(.horizontal, 32)
                .disabled(isLoading)

                if hasAPIKey {
                    Label("AI-powered data comparison with your API key", systemImage: "bolt.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else if storeManager.isPro {
                    Label("Pro: Built-in analysis included", systemImage: "crown.fill")
                        .font(.caption)
                        .foregroundStyle(Color(red: 0/255, green: 180/255, blue: 216/255))
                } else {
                    VStack(spacing: 4) {
                        Text("Free: 1 built-in analysis included")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Add an OpenAI API key in Settings for AI-powered data comparison")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .padding(.vertical, 40)
        }
    }

    private func handleAnalyzeButtonTap() {
        guard !isLoading else { return }

        if !aiConsentManager.hasConsented {
            showAIConsent = true
            return
        }

        runAnalysis()
    }

    @ViewBuilder
    private var analysisContentView: some View {
        if let analysis = currentAnalysis {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if !analysis.isAIGenerated {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .foregroundStyle(Color(red: 0/255, green: 180/255, blue: 216/255))
                            Text("Built-in Comparison — Add your OpenAI API key in Settings for deeper AI-powered comparison")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 0/255, green: 180/255, blue: 216/255).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text("This app is not intended to diagnose, treat, cure, or prevent any disease or medical condition.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        HStack(spacing: 6) {
                            Image(systemName: "person.badge.shield.checkmark")
                                .foregroundStyle(.blue)
                            Text("Users of this app must seek a doctor's advice in addition to using this app and before making any medical decisions.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    InsightSection(icon: "text.bubble", title: "Summary", color: .blue, items: [analysis.summary])

                    InsightSection(icon: "magnifyingglass", title: "Data Observations", color: .orange, items: analysis.keyFindings)

                    InsightSection(icon: "link", title: "Related Markers", color: .purple, items: analysis.correlations)

                    InsightSection(icon: "stethoscope", title: "Topics to Discuss with Your Doctor", color: .green, items: analysis.topicsToDiscuss)

                    InsightSection(icon: "arrow.right.circle", title: "Suggested Next Steps", color: Color(red: 0/255, green: 180/255, blue: 216/255), items: analysis.suggestedNextSteps)

                    citationsView

                    Button("Re-compare") {
                        currentAnalysis = nil
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 8)
                }
                .padding()
            }
        }
    }

    private var citationsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "book")
                    .foregroundStyle(Color(red: 0/255, green: 180/255, blue: 216/255))
                Text("Reference Range Sources")
                    .font(.headline)
            }

            Text("The reference ranges used for data comparison are based on established clinical laboratory reference intervals from authoritative sources:")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                CitationLink(title: "National Institutes of Health (NIH)", url: "https://www.nih.gov/health-information")
                CitationLink(title: "Mayo Clinic - Lab Tests Reference", url: "https://www.mayoclinic.org/tests-procedures")
                CitationLink(title: "Centers for Disease Control and Prevention (CDC)", url: "https://www.cdc.gov/healthyweight/healthy_eating/index.html")
                CitationLink(title: "American Heart Association", url: "https://www.heart.org/en/health-topics")
                CitationLink(title: "World Health Organization (WHO)", url: "https://www.who.int/health-topics")
            }

            Text("Reference ranges used in this app are based on standard clinical laboratory reference intervals as published by the above organizations and peer-reviewed medical literature. These ranges are for data comparison purposes only and do not constitute medical interpretation.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func runAnalysis() {
        guard let report = latestReport else { return }

        isLoading = true
        errorMessage = nil

        if hasAPIKey {
            runAIAnalysis(biomarkers: report.biomarkers)
        } else {
            runFallbackAnalysis()
        }
    }

    private func runAIAnalysis(biomarkers: [Biomarker]) {
        Task {
            do {
                let service = AIAnalysisService()
                let result = try await service.analyze(biomarkers: biomarkers, userProfile: userProfile)
                await MainActor.run {
                    currentAnalysis = result
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func runFallbackAnalysis() {
        guard let report = latestReport else { return }

        isLoading = true
        Task {
            let service = AIAnalysisService()
            let result = await service.fallbackAnalysis(biomarkers: report.biomarkers, userProfile: userProfile)
            await MainActor.run {
                currentAnalysis = result
                isLoading = false
            }
        }
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

struct CitationLink: View {
    @Environment(\.openURL) private var openURL
    let title: String
    let url: String

    var body: some View {
        Button {
            if let link = URL(string: url) {
                openURL(link)
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.up.right.square")
                    .font(.caption)
                    .foregroundStyle(Color(red: 0/255, green: 180/255, blue: 216/255))
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color(red: 0/255, green: 180/255, blue: 216/255))
            }
        }
    }
}
