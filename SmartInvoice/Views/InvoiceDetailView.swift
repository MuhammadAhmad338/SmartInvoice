//
//  InvoiceDetailView.swift
//  SmartInvoice
//
//  Created by Muhammad Ahmad on 2026-10-14.
//

import SwiftUI
import PDFKit

struct InvoiceDetailView: View {
    let invoice: Invoice

    @State private var pdfURL: URL?
    @State private var errorMessage: String?
    @State private var showingEditor = false

    var body: some View {
        List {
            Section("Invoice Details") {
                LabeledContent(
                    "Invoice Number",
                    value: invoice.invoiceNumber
                )

                LabeledContent(
                    "Business",
                    value: invoice.businessName
                )

                LabeledContent(
                    "Client",
                    value: invoice.clientName
                )

                LabeledContent(
                    "Date",
                    value: invoice.issueDate.formatted(date: .abbreviated, time: .omitted)
                )
            }

            Section("Items") {
                ForEach(invoice.items) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                            Text(
                                "\(item.quantity.formatted()) × \(item.unitPrice.formatted(.number.precision(.fractionLength(2))))"
                            )
                            .font(AppFont.style(.caption))
                            .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(
                            item.lineTotal,
                            format: .currency(code: "USD")
                        )
                    }
                }
            }

            Section("Summary") {
                LabeledContent(
                    "Subtotal",
                    value: invoice.subtotal.formatted(.currency(code: "USD"))
                )

                LabeledContent(
                    "Tax",
                    value: invoice.taxAmount.formatted(.currency(code: "USD"))
                )

                LabeledContent(
                    "Total",
                    value: invoice.total.formatted(.currency(code: "USD"))
                )
                .fontWeight(.bold)
            }

            Section("Export") {
                Button {
                    generatePDF()
                } label: {
                    Label(
                        "Generate PDF",
                        systemImage: "doc.richtext"
                    )
                }

                if let pdfURL {
                    ShareLink(item: pdfURL) {
                        Label(
                            "Share Invoice PDF",
                            systemImage: "square.and.arrow.up"
                        )
                    }

                    ShareLink(
                        item: pdfURL,
                        preview: SharePreview(
                            "\(invoice.invoiceNumber).pdf"
                        )
                    ) {
                        Label(
                            "Share PDF with Preview",
                            systemImage: "doc.text"
                        )
                    }
                }
            }
        }
        .navigationTitle(invoice.invoiceNumber)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEditor = true
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            NavigationStack {
                InvoiceEditorView(invoice: invoice)
            }
        }
        .alert(
            "PDF Export Failed",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "Please try again.")
        }
    }

    private func generatePDF() {
        do {
            pdfURL = try PDFGenerator.generate(invoice: invoice)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
