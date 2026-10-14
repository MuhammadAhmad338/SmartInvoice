import StoreKit
import SwiftUI

struct SubscriptionPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subscriptionStore: SubscriptionStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer(minLength: 8)

                Image(systemName: "sparkles")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 88, height: 88)
                    .background(Color.blue.opacity(0.1), in: Circle())

                VStack(spacing: 10) {
                    Text("Upgrade to Pro")
                        .font(AppFont.custom(size: 30, weight: .bold, relativeTo: .largeTitle))

                    Text("Create unlimited invoices and keep your business moving.")
                        .font(AppFont.custom(size: 16))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 16) {
                    benefit("Unlimited invoices", icon: "doc.text")
                    benefit("Monthly and annual plan options", icon: "calendar")
                    benefit("Your existing invoices stay available", icon: "lock.shield")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))

                if subscriptionStore.products.isEmpty {
                    if subscriptionStore.isLoading {
                        ProgressView("Loading plans…")
                            .frame(maxWidth: .infinity)
                    } else {
                        Button("Try loading plans again") {
                            Task { await subscriptionStore.loadProducts() }
                        }
                        .disabled(subscriptionStore.isLoading)
                    }
                } else {
                    VStack(spacing: 12) {
                        ForEach(subscriptionStore.products, id: \.id) { product in
                            Button {
                                Task { await subscriptionStore.purchase(product) }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(planName(for: product))
                                            .font(AppFont.custom(size: 16, weight: .semibold))
                                        Text(billingDescription(for: product))
                                            .font(AppFont.custom(size: 13))
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(product.displayPrice)
                                        .font(AppFont.custom(size: 16, weight: .bold))
                                }
                                .padding(16)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.blue.opacity(0.35), lineWidth: 1)
                            }
                            .disabled(subscriptionStore.isPurchasing)
                        }
                    }
                }

                if subscriptionStore.isPurchasing {
                    ProgressView("Processing purchase…")
                }

                if let statusMessage = subscriptionStore.statusMessage {
                    Text(statusMessage)
                        .font(AppFont.custom(size: 13))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                if let errorMessage = subscriptionStore.errorMessage {
                    Text(errorMessage)
                        .font(AppFont.custom(size: 13))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button("Restore Purchases") {
                    Task { await subscriptionStore.restorePurchases() }
                }
                .disabled(subscriptionStore.isLoading || subscriptionStore.isPurchasing)

                Link(
                    "Manage Subscription",
                    destination: URL(string: "https://apps.apple.com/account/subscriptions")!
                )
                .font(AppFont.custom(size: 13))
                .foregroundStyle(.secondary)

                Spacer(minLength: 8)
            }
            .padding(24)
            .navigationTitle("FastInvoice Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                await subscriptionStore.refreshEntitlement()
                if subscriptionStore.products.isEmpty {
                    await subscriptionStore.loadProducts()
                }
            }
        }
    }

    private func benefit(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(AppFont.custom(size: 15, weight: .medium))
    }

    private func planName(for product: Product) -> String {
        product.id == SubscriptionStore.annualProductID
            ? "Pro Annual"
            : "Pro Monthly"
    }

    private func billingDescription(for product: Product) -> String {
        guard let period = product.subscription?.subscriptionPeriod else {
            return "Auto-renewing subscription"
        }

        let unit: String
        switch period.unit {
        case .day: unit = period.value == 1 ? "day" : "days"
        case .week: unit = period.value == 1 ? "week" : "weeks"
        case .month: unit = period.value == 1 ? "month" : "months"
        case .year: unit = period.value == 1 ? "year" : "years"
        @unknown default: unit = "period"
        }
        return "Billed every \(period.value) \(unit). Auto-renews."
    }
}
