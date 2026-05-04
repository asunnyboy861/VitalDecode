import SwiftUI
import SwiftData

@main
struct VitalDecodeApp: App {
    @State private var userProfile = UserProfile()
    @State private var storeManager = StoreManager()
    @State private var healthKitManager = HealthKitManager()

    var body: some Scene {
        WindowGroup {
            if userProfile.hasCompletedOnboarding {
                ContentView(userProfile: userProfile, storeManager: storeManager, healthKitManager: healthKitManager)
            } else {
                OnboardingView(hasCompletedOnboarding: $userProfile.hasCompletedOnboarding)
            }
        }
        .modelContainer(for: [BloodTestReport.self, Biomarker.self])
    }
}
