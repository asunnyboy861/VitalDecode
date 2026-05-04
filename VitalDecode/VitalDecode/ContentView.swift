import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    let userProfile: UserProfile
    let storeManager: StoreManager
    let healthKitManager: HealthKitManager

    var body: some View {
        TabView(selection: $selectedTab) {
            ScanView(userProfile: userProfile, storeManager: storeManager)
                .tabItem {
                    Label("Scan", systemImage: "doc.text.viewfinder")
                }
                .tag(0)

            ResultsView()
                .tabItem {
                    Label("Results", systemImage: "list.bullet.clipboard")
                }
                .tag(1)

            TrendsView(storeManager: storeManager)
                .tabItem {
                    Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)

            InsightsView(userProfile: userProfile, storeManager: storeManager)
                .tabItem {
                    Label("Insights", systemImage: "brain.head.profile")
                }
                .tag(3)

            SettingsView(userProfile: userProfile, bindableProfile: userProfile, storeManager: storeManager, healthKitManager: healthKitManager)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(4)
        }
        .tint(Color(red: 0/255, green: 180/255, blue: 216/255))
    }
}
