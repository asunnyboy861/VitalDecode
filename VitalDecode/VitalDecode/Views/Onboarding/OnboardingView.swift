import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var hasAcceptedDisclaimer = false

    private let totalPages = 4

    var body: some View {
        TabView(selection: $currentPage) {
            onboardingPage(
                icon: "doc.text.viewfinder",
                title: "Scan Your Results",
                subtitle: "Take a photo of your blood test report or upload a PDF. Our advanced OCR reads it instantly."
            ).tag(0)

            onboardingPage(
                icon: "chart.bar.doc.horizontal",
                title: "Compare to Reference Ranges",
                subtitle: "See your results compared to standard and optimal reference ranges. Know which values are in range."
            ).tag(1)

            onboardingPage(
                icon: "brain.head.profile",
                title: "Get Data Insights",
                subtitle: "Compare your numbers to reference ranges and get topics to discuss with your healthcare provider."
            ).tag(2)

            disclaimerPage.tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .overlay(alignment: .bottom) {
            VStack(spacing: 16) {
                if currentPage < totalPages - 1 {
                    Button("Next") {
                        withAnimation { currentPage += 1 }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0/255, green: 180/255, blue: 216/255))
                    .controlSize(.large)
                } else {
                    Button("I Understand & Get Started") {
                        hasCompletedOnboarding = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0/255, green: 180/255, blue: 216/255))
                    .controlSize(.large)
                    .disabled(!hasAcceptedDisclaimer)
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

    private var disclaimerPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.orange)

            Text("Important Disclaimer")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 16) {
                DisclaimerRow(
                    icon: "stethoscope",
                    color: .red,
                    title: "Not a Medical Device",
                    description: "VitalDecode is a data reference tool. It does not provide medical diagnosis, treatment advice, or health assessments."
                )

                DisclaimerRow(
                    icon: "person.badge.shield.checkmark",
                    color: .blue,
                    title: "Consult Your Doctor",
                    description: "Always seek a doctor's advice in addition to using this app and before making any medical decisions."
                )

                DisclaimerRow(
                    icon: "chart.bar",
                    color: .green,
                    title: "Reference Ranges Only",
                    description: "Reference ranges shown are for data comparison purposes only and do not constitute medical interpretation of your lab results."
                )
            }
            .padding(.horizontal, 24)

            Toggle(isOn: $hasAcceptedDisclaimer) {
                Text("I understand this is not a medical device and I should consult a healthcare professional for medical advice.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 32)

            Spacer()
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

struct DisclaimerRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
