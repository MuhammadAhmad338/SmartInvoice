import SwiftUI
import SwiftData

private struct InvoiceLineDraft: Identifiable {
    let id: UUID
    var title: String
    var quantity: Double
    var unitPrice: Double

    init(
        id: UUID = UUID(),
        title: String,
        quantity: Double,
        unitPrice: Double
    ) {
        self.id = id
        self.title = title
        self.quantity = quantity
        self.unitPrice = unitPrice
    }

    var total: Double {
        quantity * unitPrice
    }
}

struct InvoiceEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let invoice: Invoice?
    private let onCreate: () -> Void

    @State private var businessName = ""
    @State private var clientName = ""
    @State private var paymentTerms = "Due within 14 days"
    @State private var taxRate = "0"

    @State private var itemTitle = ""
    @State private var quantity = "1"
    @State private var unitPrice = ""

    @State private var items: [InvoiceLineDraft] = []
    @State private var errorMessage: String?

    init(
        invoice: Invoice? = nil,
        onCreate: @escaping () -> Void = {}
    ) {
        self.invoice = invoice
        self.onCreate = onCreate
        _businessName = State(initialValue: invoice?.businessName ?? "")
        _clientName = State(initialValue: invoice?.clientName ?? "")
        _paymentTerms = State(
            initialValue: invoice?.paymentTerms ?? "Due within 14 days"
        )
        _taxRate = State(initialValue: String(invoice?.taxRate ?? 0))
        _items = State(
            initialValue: invoice?.items.map {
                InvoiceLineDraft(
                    id: $0.id,
                    title: $0.title,
                    quantity: $0.quantity,
                    unitPrice: $0.unitPrice
                )
            } ?? []
        )
    }

    private var subtotal: Double {
        items.reduce(0) { $0 + $1.total }
    }

    private var taxAmount: Double {
        subtotal * (Double(taxRate) ?? 0) / 100
    }

    private var grandTotal: Double {
        subtotal + taxAmount
    }

    var body: some View {
        Form {
            Section("Your Business") {
                TextField("Business or freelancer name", text: $businessName)
            }

            Section("Client Details") {
                TextField("Client name", text: $clientName)
            }

            Section("Line Items") {
                TextField("Description", text: $itemTitle)

                TextField("Quantity", text: $quantity)
                    .keyboardType(.decimalPad)

                TextField("Unit price (USD)", text: $unitPrice)
                    .keyboardType(.decimalPad)

                Button(action: addItem) {
                    Label("Add Line Item", systemImage: "plus.circle.fill")
                }
                .disabled(
                    itemTitle.trimmingCharacters(in: .whitespaces).isEmpty
                    || (Double(quantity) ?? 0) <= 0
                    || (Double(unitPrice) ?? -1) < 0
                )

                ForEach(items) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(AppFont.style(.subheadline))

                            Text(
                                "\(item.quantity.formatted()) × \(item.unitPrice.formatted(.number.precision(.fractionLength(2))))"
                            )
                            .font(AppFont.style(.caption))
                            .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(item.total, format: .currency(code: "USD"))
                            .fontWeight(.medium)
                    }
                }
                .onDelete { offsets in
                    items.remove(atOffsets: offsets)
                }
            }

            Section("Tax & Payment") {
                TextField("Tax percentage", text: $taxRate)
                    .keyboardType(.decimalPad)

                TextField("Payment terms", text: $paymentTerms)
            }

            Section("Summary (USD)") {
                LabeledContent(
                    "Subtotal",
                    value: subtotal.formatted(.currency(code: "USD"))
                )

                LabeledContent(
                    "Tax",
                    value: taxAmount.formatted(.currency(code: "USD"))
                )

                LabeledContent(
                    "Total",
                    value: grandTotal.formatted(.currency(code: "USD"))
                )
                .fontWeight(.bold)
            }

            Section {
                Button(action: saveInvoice) {
                    Text(invoice == nil ? "Save Invoice" : "Save Changes")
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                }
                .disabled(
                    businessName.trimmingCharacters(in: .whitespaces).isEmpty
                    || clientName.trimmingCharacters(in: .whitespaces).isEmpty
                    || items.isEmpty
                    || (Double(taxRate) ?? -1) < 0
                )
            }
        }
        .navigationTitle(invoice == nil ? "New Invoice" : "Edit Invoice")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert(
            "Unable to Save",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Please try again.")
        }
    }

    private func addItem() {
        guard
            !itemTitle.trimmingCharacters(in: .whitespaces).isEmpty,
            let itemQuantity = Double(quantity),
            let price = Double(unitPrice),
            itemQuantity > 0,
            price >= 0
        else {
            return
        }

        items.append(
            InvoiceLineDraft(
                title: itemTitle.trimmingCharacters(in: .whitespaces),
                quantity: itemQuantity,
                unitPrice: price
            )
        )

        itemTitle = ""
        quantity = "1"
        unitPrice = ""
    }

    private func saveInvoice() {
        guard
            let tax = Double(taxRate),
            tax >= 0,
            tax <= 100
        else {
            errorMessage = "Tax percentage must be between 0 and 100."
            return
        }

        let invoiceToSave: Invoice
        if let invoice {
            invoice.businessName = businessName.trimmingCharacters(
                in: .whitespaces
            )
            invoice.clientName = clientName.trimmingCharacters(
                in: .whitespaces
            )
            invoice.paymentTerms = paymentTerms
            invoice.taxRate = tax
            invoiceToSave = invoice
        } else {
            invoiceToSave = Invoice(
                businessName: businessName.trimmingCharacters(
                    in: .whitespaces
                ),
                clientName: clientName.trimmingCharacters(
                    in: .whitespaces
                ),
                paymentTerms: paymentTerms,
                taxRate: tax
            )
            modelContext.insert(invoiceToSave)
        }

        let existingItems = invoiceToSave.items
        for existingItem in existingItems {
            if let draft = items.first(where: { $0.id == existingItem.id }) {
                existingItem.title = draft.title
                existingItem.quantity = draft.quantity
                existingItem.unitPrice = draft.unitPrice
            } else {
                invoiceToSave.items.removeAll { $0.id == existingItem.id }
                modelContext.delete(existingItem)
            }
        }

        let existingItemIDs = Set(existingItems.map(\.id))
        for draft in items where !existingItemIDs.contains(draft.id) {
            let item = InvoiceItem(
                title: draft.title,
                quantity: draft.quantity,
                unitPrice: draft.unitPrice
            )
            item.invoice = invoiceToSave
            invoiceToSave.items.append(item)
        }

        do {
            try modelContext.save()
            if invoice == nil {
                onCreate()
            }
            dismiss()
        } catch {
            modelContext.rollback()
            errorMessage = error.localizedDescription
        }
    }
}
