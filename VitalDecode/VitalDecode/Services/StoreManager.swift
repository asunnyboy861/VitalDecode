import Foundation
import StoreKit

@Observable
final class StoreManager {

    enum SubscriptionTier: String, CaseIterable {
        case monthly = "com.zzoutuo.VitalDecode.proMonthly"
        case annual = "com.zzoutuo.VitalDecode.proAnnual"
        case lifetime = "com.zzoutuo.VitalDecode.lifetime"
    }

    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isPro: Bool = false
    var isLoading: Bool = true

    private var transactionListener: Task<Void, Never>?

    init() {
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
    }

    deinit {
        transactionListener?.cancel()
    }

    var monthlyProduct: Product? {
        products.first { $0.id == SubscriptionTier.monthly.rawValue }
    }

    var annualProduct: Product? {
        products.first { $0.id == SubscriptionTier.annual.rawValue }
    }

    var lifetimeProduct: Product? {
        products.first { $0.id == SubscriptionTier.lifetime.rawValue }
    }

    func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: SubscriptionTier.allCases.map(\.rawValue))
            products = storeProducts.sorted { $0.price < $1.price }
            await updatePurchasedProducts()
        } catch {
            products = []
        }
        isLoading = false
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchasedProducts()
                await transaction.finish()
                return true
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            return false
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {}
    }

    // MARK: - Public method to refresh subscription status
    func refreshSubscriptionStatus() async {
        await updatePurchasedProducts()
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                } catch {}
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    private func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                purchasedIDs.insert(transaction.productID)
            } catch {}
        }

        purchasedProductIDs = purchasedIDs
        isPro = !purchasedIDs.isEmpty
    }

    enum StoreError: Error {
        case verificationFailed
    }
}
