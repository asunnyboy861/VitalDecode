import SwiftUI
import StoreKit

struct PaywallView: View {
    let storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTier: StoreManager.SubscriptionTier = .annual
    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "heart.text.square")
                        .font(.system(size: 56))
                        .foregroundStyle(Color(red: 0/255, green: 180/255, blue: 216/255))

                    Text("Unlock VitalDecode Pro")
                        .font(.title)
                        .bold()

                    Text("Get unlimited scans, AI insights, trend tracking, and more.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        if let product = storeManager.annualProduct {
                            tierCard(
                                tier: .annual,
                                title: "Yearly",
                                price: product.displayPrice,
                                subtitle: "Best Value",
                                badge: "SAVE 50%"
                            )
                        }

                        if let product = storeManager.monthlyProduct {
                            tierCard(
                                tier: .monthly,
                                title: "Monthly",
                                price: product.displayPrice,
                                subtitle: "per month",
                                badge: nil
                            )
                        }

                        if let product = storeManager.lifetimeProduct {
                            tierCard(
                                tier: .lifetime,
                                title: "Lifetime",
                                price: product.displayPrice,
                                subtitle: "One-time purchase",
                                badge: nil
                            )
                        }
                    }
                    .padding(.horizontal)

                    featureList

                    Button {
                        purchase()
                    } label: {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Subscribe Now")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0/255, green: 180/255, blue: 216/255))
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .disabled(isPurchasing)

                    Button("Restore Purchases") {
                        Task { await storeManager.restorePurchases() }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    Text("Cancel anytime. Subscription auto-renews.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func tierCard(tier: StoreManager.SubscriptionTier, title: String, price: String, subtitle: String, badge: String?) -> some View {
        Button {
            selectedTier = tier
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.headline)
                        if let badge {
                            Text(badge)
                                .font(.caption2)
                                .bold()
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(red: 0/255, green: 180/255, blue: 216/255))
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(price)
                    .font(.title3)
                    .bold()
                Image(systemName: selectedTier == tier ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selectedTier == tier ? Color(red: 0/255, green: 180/255, blue: 216/255) : .secondary)
            }
            .padding()
            .background(selectedTier == tier ? Color(red: 0/255, green: 180/255, blue: 216/255).opacity(0.1) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedTier == tier ? Color(red: 0/255, green: 180/255, blue: 216/255) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 12) {
            featureRow(icon: "infinity", text: "Unlimited Scans")
            featureRow(icon: "brain.head.profile", text: "AI-Powered Insights")
            featureRow(icon: "chart.line.uptrend.xyaxis", text: "Trend Tracking")
            featureRow(icon: "person.2", text: "Multi-Profile Support")
            featureRow(icon: "square.and.arrow.up", text: "PDF & CSV Export")
            featureRow(icon: "heart.text.square", text: "HealthKit Integration")
        }
        .padding()
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color(red: 0/255, green: 180/255, blue: 216/255))
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
        }
    }

    private func purchase() {
        guard let product = storeManager.products.first(where: { $0.id == selectedTier.rawValue }) else { return }
        isPurchasing = true
        Task {
            let success = await storeManager.purchase(product)
            isPurchasing = false
            if success {
                dismiss()
            }
        }
    }
}
