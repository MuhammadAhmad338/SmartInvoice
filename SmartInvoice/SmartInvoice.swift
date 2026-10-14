
import SwiftUI
import SwiftData

@main
struct SmartInvoice: App {
    @StateObject private var subscriptionStore = SubscriptionStore()

    init() {
        do {
            try GoogleSansFlexFont.register()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    var body: some Scene {
        WindowGroup {
            LaunchFlowView()
                .font(AppFont.custom(size: 17))
                .environmentObject(subscriptionStore)
        }
        .modelContainer(
            for: [Invoice.self, InvoiceItem.self]
        )
    }
}
