import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            onboardingPage(
                icon: "doc.text.viewfinder",
                title: "Scan Your Results",
                subtitle: "Take a photo of your blood test report or upload a PDF. Our advanced OCR reads it instantly."
            ).tag(0)

            onboardingPage(
                icon: "chart.bar.doc.horizontal",
                title: "Decode Every Number",
                subtitle: "See your results with dual ranges: standard vs. optimal. Know when 'normal' isn't your best."
            ).tag(1)

            onboardingPage(
                icon: "brain.head.profile",
                title: "Get AI Insights",
                subtitle: "Understand what your numbers mean in plain English with personalized recommendations."
            ).tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .overlay(alignment: .bottom) {
            VStack(spacing: 16) {
                if currentPage < 2 {
                    Button("Next") {
                        withAnimation { currentPage += 1 }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0/255, green: 180/255, blue: 216/255))
                    .controlSize(.large)
                } else {
                    Button("Get Started") {
                        hasCompletedOnboarding = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0/255, green: 180/255, blue: 216/255))
                    .controlSize(.large)
                }

                if currentPage > 0 {
                    Button("Skip") {
                        hasCompletedOnboarding = true
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, 50)
        }
    }

    private func onboardingPage(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 72))
                .foregroundStyle(Color(red: 0/255, green: 180/255, blue: 216/255))

            Text(title)
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }
}
