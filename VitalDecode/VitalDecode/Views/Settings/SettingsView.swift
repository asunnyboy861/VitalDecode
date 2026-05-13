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
        }
    }

    private var aiSection: some View {
        Section("AI Analysis") {
            SecureField("OpenAI API Key", text: $apiKey)
                .onChange(of: apiKey) { _, newValue in
                    UserDefaults.standard.set(newValue, forKey: "openai_api_key")
                }
            if apiKey.isEmpty {
                Text("Enter your OpenAI API key to enable AI insights, or upgrade to Pro.")
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
        Section("HealthKit") {
            if healthKitManager.isAvailable {
                HStack {
                    Text("Connected")
                    Spacer()
                    Text(healthKitManager.isAuthorized ? "Yes" : "No")
                        .foregroundStyle(healthKitManager.isAuthorized ? .green : .secondary)
                }
                if !healthKitManager.isAuthorized {
                    Button("Enable HealthKit") {
                        Task {
                            _ = try? await healthKitManager.requestAuthorization()
                        }
                    }
                }
            } else {
                Text("HealthKit is not available on this device")
                    .foregroundStyle(.secondary)
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
            rootVC.present(activityVC, animated: true)
        }
    }
}
