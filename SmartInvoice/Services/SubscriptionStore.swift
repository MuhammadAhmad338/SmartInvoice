import Foundation
import Combine
import StoreKit

@MainActor
final class SubscriptionStore: ObservableObject {
    static let freeInvoiceLimit = 3

    static let monthlyProductID = "com.smartinvoice.pro.monthly"
    static let annualProductID = "com.smartinvoice.pro.annual"
    static let productIDs = [
        monthlyProductID,
        annualProductID
    ]

    @Published private(set) var products: [Product] = []
    @Published private(set) var isPro = false
    @Published private(set) var invoiceCreationCount = 0
    @Published private(set) var isLoading = false
    @Published private(set) var isPurchasing = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var statusMessage: String?

    private var transactionUpdatesTask: Task<Void, Never>?

    init() {
        invoiceCreationCount = UserDefaults.standard.integer(
            forKey: Self.invoiceCreationCountKey
        )

        transactionUpdatesTask = Task { [weak self] in
            for await verificationResult in Transaction.updates {
                guard let self else { return }

                if case .verified(let transaction) = verificationResult {
                    await transaction.finish()
                } else {
                    self.errorMessage =
                        "A purchase update could not be verified."
                }

                await self.refreshEntitlement()
            }
        }

        Task {
            await loadProducts()
            await refreshEntitlement()
        }
    }

    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let fetchedProducts = try await Product.products(
                for: Self.productIDs
            )
            products = fetchedProducts.sorted {
                (Self.productIDs.firstIndex(of: $0.id) ?? Int.max)
                    < (Self.productIDs.firstIndex(of: $1.id) ?? Int.max)
            }

            let missingProducts = Set(Self.productIDs).subtracting(
                Set(fetchedProducts.map(\.id))
            )
            if !missingProducts.isEmpty {
                errorMessage =
                    "Subscription products are not available: "
                    + missingProducts.sorted().joined(separator: ", ")
                    + ". Configure these product IDs in App Store Connect."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func purchase(_ product: Product) async {
        isPurchasing = true
        errorMessage = nil
        statusMessage = nil
        defer { isPurchasing = false }

        do {
            switch try await product.purchase() {
            case .success(let verificationResult):
                let transaction = try Self.verifiedTransaction(
                    from: verificationResult
                )
                await transaction.finish()
                await refreshEntitlement()
                statusMessage = isPro
                    ? "Pro is active. You can now create unlimited invoices."
                    : "The purchase completed, but the Pro entitlement is not active yet."

            case .pending:
                statusMessage =
                    "Your purchase is pending approval. Pro will activate when it is approved."

            case .userCancelled:
                break

            @unknown default:
                errorMessage = "The purchase result was not recognized."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        statusMessage = nil
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await refreshEntitlement()
            statusMessage = isPro
                ? "Your Pro subscription has been restored."
                : "No active Pro subscription was found for this Apple Account."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshEntitlement() async {
        var hasActiveSubscription = false

        for await verificationResult in Transaction.currentEntitlements {
            guard case .verified(let transaction) = verificationResult else {
                if case .unverified(let transaction, _) = verificationResult,
                    Self.productIDs.contains(transaction.productID) {
                    errorMessage =
                        "The App Store could not verify the current subscription."
                }
                continue
            }

            guard
                Self.productIDs.contains(transaction.productID),
                transaction.productType == .autoRenewable,
                transaction.revocationDate == nil,
                transaction.expirationDate.map({ $0 > .now }) ?? true
            else {
                continue
            }

            hasActiveSubscription = true
            break
        }

        isPro = hasActiveSubscription
    }

    func recordExistingInvoiceCount(_ count: Int) {
        updateInvoiceCreationCount(toAtLeast: count)
    }

    func recordInvoiceCreated() {
        updateInvoiceCreationCount(toAtLeast: invoiceCreationCount + 1)
    }

    private func updateInvoiceCreationCount(toAtLeast count: Int) {
        guard count > invoiceCreationCount else { return }

        invoiceCreationCount = count
        UserDefaults.standard.set(
            count,
            forKey: Self.invoiceCreationCountKey
        )
    }

    private static let invoiceCreationCountKey =
        "subscription.invoiceCreationCount"

    private static func verifiedTransaction(
        from result: VerificationResult<Transaction>
    ) throws -> Transaction {
        switch result {
        case .verified(let transaction):
            return transaction
        case .unverified:
            throw SubscriptionError.unverifiedTransaction
        }
    }
}

private enum SubscriptionError: LocalizedError {
    case unverifiedTransaction

    var errorDescription: String? {
        "The App Store could not verify this purchase."
    }
}
