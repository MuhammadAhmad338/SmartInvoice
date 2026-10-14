import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var subscriptionStore: SubscriptionStore

    @Query(sort: \Invoice.issueDate, order: .reverse)
    private var invoices: [Invoice]

    @State private var showingEditor = false
    @State private var showingPaywall = false

    private var canCreateInvoice: Bool {
        subscriptionStore.isPro
            || max(invoices.count, subscriptionStore.invoiceCreationCount)
                < SubscriptionStore.freeInvoiceLimit
    }

    var body: some View {
        NavigationStack {
            Group {
                if invoices.isEmpty {
                    ContentUnavailableView(
                        "No Invoices Yet",
                        systemImage: "doc.text",
                        description: Text(
                            "Create your first professional invoice."
                        )
                    )
                } else {
                    List {
                        ForEach(invoices) { invoice in
                            NavigationLink {
                                InvoiceDetailView(invoice: invoice)
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(invoice.clientName)
                                        .font(AppFont.style(.headline, weight: .semibold))

                                    Text(invoice.invoiceNumber)
                                        .font(AppFont.style(.caption))
                                        .foregroundStyle(.secondary)

                                    HStack {
                                        Text(invoice.issueDate, style: .date)
                                        Spacer()
                                        Text(
                                            invoice.total,
                                            format: .currency(code: "USD")
                                        )
                                        .fontWeight(.semibold)
                                    }
                                    .font(AppFont.style(.subheadline))
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: deleteInvoices)
                    }
                }
            }
            .navigationTitle("FastInvoice")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if canCreateInvoice {
                            showingEditor = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Label("New Invoice", systemImage: "plus")
                    }
                    .accessibilityHint(
                        canCreateInvoice
                            ? "Create a new invoice"
                            : "Upgrade to Pro to create more invoices"
                    )
                }

                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        showingPaywall = true
                    } label: {
                        Label(
                            subscriptionStore.isPro ? "Pro Active" : "Pro",
                            systemImage: subscriptionStore.isPro
                                ? "checkmark.seal.fill"
                                : "sparkles"
                        )
                    }

                    if !invoices.isEmpty {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                NavigationStack {
                    InvoiceEditorView {
                        subscriptionStore.recordInvoiceCreated()
                    }
                }
            }
            .sheet(isPresented: $showingPaywall) {
                SubscriptionPaywallView()
            }
            .task {
                subscriptionStore.recordExistingInvoiceCount(invoices.count)
            }
        }
    }

    private func deleteInvoices(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(invoices[index])
        }

        try? modelContext.save()
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [Invoice.self, InvoiceItem.self],
            inMemory: true
        )
        .environmentObject(SubscriptionStore())
}
