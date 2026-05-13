import SwiftUI

struct AIConsentView: View {
    @Environment(\.dismiss) private var dismiss
    let onConsentGranted: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    descriptionSection
                    consentItemsSection
                    actionButtons
                    privacyFooter
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 56))
                .foregroundStyle(Color(red: 0/255, green: 180/255, blue: 216/255))

            Text("Before Your Data is Analyzed")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
        }
    }

    private var descriptionSection: some View {
        Text("To provide AI-powered insights, VitalDecode sends your health information to OpenAI. Please review the details below before continuing.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }

    private var consentItemsSection: some View {
        VStack(spacing: 12) {
            ConsentItem(
                icon: "doc.text.fill",
                title: "What We Send",
                description: "Your test results (biomarker names, values, and reference ranges), along with your age and gender"
            )

            ConsentItem(
                icon: "building.2.fill",
                title: "Who Receives Your Data",
                description: "OpenAI (api.openai.com) processes this data to generate health insights for you"
            )

            ConsentItem(
                icon: "lock.shield.fill",
                title: "How Your Data is Protected",
                description: "OpenAI uses this data only to provide the analysis service and does not use it for AI training"
            )

            ConsentItem(
                icon: "person.crop.circle.badge.checkmark",
                title: "Your Control",
                description: "You can revoke this permission anytime in Settings → AI Analysis"
            )
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                onConsentGranted()
                dismiss()
            } label: {
                Text("I Understand & Continue")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0/255, green: 180/255, blue: 216/255))

            Button("Not Now") {
                dismiss()
            }
            .foregroundStyle(.secondary)
        }
    }

    private var privacyFooter: some View {
        Text("By continuing, you agree to our [Privacy Policy](https://asunnyboy861.github.io/VitalDecode/privacy.html) and acknowledge that OpenAI processes your data according to their [Privacy Policy](https://openai.com/policies/privacy-policy).")
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.top, 8)
    }
}

struct ConsentItem: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color(red: 0/255, green: 180/255, blue: 216/255))
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
