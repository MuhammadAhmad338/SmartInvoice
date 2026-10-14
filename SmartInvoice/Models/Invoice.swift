//
//  Invoice.swift
//  MyApp
//
//  Created by Muhammad Ahmad on 2026-10-14.
//
import Foundation
import SwiftData

@Model
final class Invoice {
    var id: UUID
    var invoiceNumber: String
    var businessName: String
    var clientName: String
    var paymentTerms: String
    var issueDate: Date
    var taxRate: Double

    @Relationship(deleteRule: .cascade, inverse: \InvoiceItem.invoice)
    var items: [InvoiceItem] = []

    init(
        invoiceNumber: String = "INV-\(Int.random(in: 1000...9999))",
        businessName: String = "",
        clientName: String = "",
        paymentTerms: String = "Due within 14 days",
        issueDate: Date = .now,
        taxRate: Double = 0
    ) {
        self.id = UUID()
        self.invoiceNumber = invoiceNumber
        self.businessName = businessName
        self.clientName = clientName
        self.paymentTerms = paymentTerms
        self.issueDate = issueDate
        self.taxRate = taxRate
    }

    var subtotal: Double {
        items.reduce(0) { $0 + $1.lineTotal }
    }

    var taxAmount: Double {
        subtotal * taxRate / 100
    }

    var total: Double {
        subtotal + taxAmount
    }
}

@Model
final class InvoiceItem {
    var id: UUID
    var title: String
    var quantity: Double
    var unitPrice: Double

    var invoice: Invoice?

    init(
        title: String,
        quantity: Double,
        unitPrice: Double
    ) {
        self.id = UUID()
        self.title = title
        self.quantity = quantity
        self.unitPrice = unitPrice
    }

    var lineTotal: Double {
        quantity * unitPrice
    }
}
