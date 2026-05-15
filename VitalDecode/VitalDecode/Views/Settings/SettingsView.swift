import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL

    let userProfile: UserProfile
    @Bindable var bindableProfile: UserProfile
    let storeManager: StoreManager
    let healthKitManager: HealthKitManager
    let aiConsentManager: AIConsentManager

    @State private var apiKey = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
    @State private var showDeleteConfirmation = false

    private let supportURL = URL(string: "https://asunnyboy861.github.io/VitalDecode/support.html")!
    private let privacyURL = URL(string: "https://asunnyboy861.github.io/VitalDecode/privacy.html")!
    private let termsURL = URL(string: "https://asunnyboy861.github.io/VitalDecode/terms.html")!

    var body: some View {
        NavigationStack {
            Form {
                profileSection
                subscriptionSection
                aiSection
                healthKitSection
                dataSection
                aboutSection
            }
            .navigationTitle("Settings")
        }
    }

    private var profileSection: some View {
        Section("Profile") {
            TextField("Name", text: $bindableProfile.name)
            Stepper("Age: \(bindableProfile.age)", value: $bindableProfile.age, in: 1...120)
            Picker("Gender", selection: $bindableProfile.gender) {
                ForEach(UserProfile.Gender.allCases, id: \.self) { gender in
                    Text(gender.rawValue).tag(gender)
                }
            }
        }
    }

    private var subscriptionSection: some View {
        Section("Subscription") {
            HStack {
                Text("Status")
                Spacer()
                Text(storeManager.isPro ? "Pro" : "Free")
                    .foregroundStyle(storeManager.isPro ? .green : .secondary)
            }
            if !storeManager.isPro {
                NavigationLink {
                    PaywallView(storeManager: storeManager)
                } label: {
                    Text("Upgrade to Pro")
                }
            }
            Button("Restore Purchases") {
                Task { await storeManager.restorePurchases() }
            }
            if storeManager.isPro {
                Button("Reset Subscription (App Review)") {
                    Task {
                        await storeManager.resetSubscriptionState()
                    }
                }
                .foregroundStyle(.orange)
            }
        }
    }

    private var aiSection: some View {
        Section("AI Data Comparison") {
            SecureField("OpenAI API Key", text: $apiKey)
                .onChange(of: apiKey) { _, newValue in
                    UserDefaults.standard.set(newValue, forKey: "openai_api_key")
                }
            if apiKey.isEmpty {
                Text("Enter your OpenAI API key to enable AI data comparison, or upgrade to Pro.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if aiConsentManager.hasConsented {
                Button("Reset AI Data Consent") {
                    aiConsentManager.revokeConsent()
                }
                .foregroundStyle(.orange)
            }
        }
    }

    private var healthKitSection: some View {
        Section {
            if healthKitManager.isAvailable {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                    Text("Apple Health (HealthKit)")
                        .font(.subheadline)
                    Spacer()
                    Text(healthKitManager.isAuthorized ? "Connected" : "Not Connected")
                        .foregroundStyle(healthKitManager.isAuthorized ? .green : .secondary)
                        .font(.caption)
                }

                if healthKitManager.isAuthorized {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Reads blood glucose, heart rate, blood pressure, and body measurements from Apple Health", systemImage: "arrow.down.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Label("Your blood test results are stored locally on your device", systemImage: "lock.shield")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }

                if !healthKitManager.isAuthorized {
                    Button("Connect Apple Health") {
                        Task {
                            _ = try? await healthKitManager.requestAuthorization()
                        }
                    }
                    Text("VitalDecode reads data from Apple Health to display alongside your lab results. No data is written to Apple Health.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                HStack {
                    Image(systemName: "heart.slash")
                        .foregroundStyle(.secondary)
                    Text("Apple Health is not available on this device")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            HStack(spacing: 4) {
                Text("Apple Health")
                Image(systemName: "heart.text.square")
                    .foregroundStyle(.red)
            }
        }
    }

    private var dataSection: some View {
        Section("Data") {
            Button("Export All Reports (CSV)", action: exportCSV)
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Text("Delete All Reports")
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            NavigationLink {
                ContactSupportView()
            } label: {
                Label("Contact Support", systemImage: "envelope")
            }
            Button("Privacy Policy") { openURL(privacyURL) }
            Button("Terms of Use") { openURL(termsURL) }
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func exportCSV() {
        let descriptor = FetchDescriptor<BloodTestReport>()
        guard let reports = try? modelContext.fetch(descriptor) else { return }
        let allBiomarkers = reports.flatMap(\.biomarkers)
        let csv = ExportService.exportCSV(biomarkers: allBiomarkers)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("vitaldecode_export.csv")
        try? csv.write(to: tempURL, atomically: true, encoding: .utf8)
        let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            activityVC.popoverPresentationController?.sourceView = rootVC.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(
                x: rootVC.view.bounds.midX,
                y: rootVC.view.bounds.midY,
                width: 0,
                height: 0
            )
            rootVC.present(activityVC, animated: true)
        }
    }
}
