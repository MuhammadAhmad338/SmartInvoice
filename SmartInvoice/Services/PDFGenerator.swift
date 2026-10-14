import Foundation
import UIKit

enum PDFGenerator {
    private enum PDFError: LocalizedError {
        case fontUnavailable

        var errorDescription: String? {
            "Google Sans Flex is unavailable for PDF generation."
        }
    }

    static func generate(invoice: Invoice) throws -> URL {
        guard
            let regularFont = UIFont(
                name: GoogleSansFlexFont.familyName,
                size: 12
            ),
            let boldFont = UIFont(name: "GoogleSansFlex-Bold", size: 12),
            let italicFont = UIFont(name: "GoogleSansFlex-Italic", size: 12)
        else {
            throw PDFError.fontUnavailable
        }

        // A4 page dimensions in points
        let pageRect = CGRect(
            x: 0,
            y: 0,
            width: 595.2,
            height: 841.8
        )

        let renderer = UIGraphicsPDFRenderer(
            bounds: pageRect
        )

        let data = renderer.pdfData { context in
            context.beginPage()

            let margin: CGFloat = 40
            let contentWidth = pageRect.width - margin * 2

            func drawText(
                _ text: String,
                x: CGFloat,
                y: CGFloat,
                width: CGFloat,
                font: UIFont,
                color: UIColor = .darkGray,
                alignment: NSTextAlignment = .left
            ) {
                let paragraph = NSMutableParagraphStyle()
                paragraph.alignment = alignment

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: paragraph
                ]

                (text as NSString).draw(
                    in: CGRect(
                        x: x,
                        y: y,
                        width: width,
                        height: 40
                    ),
                    withAttributes: attributes
                )
            }

            func drawLine(y: CGFloat) {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: margin, y: y))
                path.addLine(
                    to: CGPoint(x: pageRect.width - margin, y: y)
                )
                UIColor.lightGray.setStroke()
                path.lineWidth = 0.5
                path.stroke()
            }

            drawText(
                invoice.businessName,
                x: margin,
                y: 45,
                width: contentWidth,
                font: boldFont.withSize(24),
                color: .black
            )

            drawText(
                "INVOICE",
                x: margin,
                y: 95,
                width: contentWidth,
                font: boldFont.withSize(28),
                color: .systemBlue
            )

            drawText(
                "Invoice #: \(invoice.invoiceNumber)",
                x: margin,
                y: 140,
                width: contentWidth,
                font: regularFont
            )

            drawText(
                "Date: \(invoice.issueDate.formatted(date: .abbreviated, time: .omitted))",
                x: margin,
                y: 160,
                width: contentWidth,
                font: regularFont
            )

            drawText(
                "Bill To: \(invoice.clientName)",
                x: margin,
                y: 205,
                width: contentWidth,
                font: boldFont.withSize(14),
                color: .black
            )

            drawLine(y: 245)

            let quantityX = margin + contentWidth * 0.65
            let priceX = margin + contentWidth * 0.78
            let totalX = margin + contentWidth * 0.88

            drawText(
                "Description",
                x: margin,
                y: 258,
                width: contentWidth * 0.60,
                font: boldFont.withSize(11)
            )

            drawText(
                "Qty",
                x: quantityX,
                y: 258,
                width: contentWidth * 0.12,
                font: boldFont.withSize(11),
                alignment: .right
            )

            drawText(
                "Price",
                x: priceX,
                y: 258,
                width: contentWidth * 0.10,
                font: boldFont.withSize(11),
                alignment: .right
            )

            drawText(
                "Total",
                x: totalX,
                y: 258,
                width: contentWidth * 0.12,
                font: boldFont.withSize(11),
                alignment: .right
            )

            drawLine(y: 280)

            var y: CGFloat = 292

            for item in invoice.items {
                drawText(
                    item.title,
                    x: margin,
                    y: y,
                    width: contentWidth * 0.60,
                    font: regularFont.withSize(10)
                )

                drawText(
                    item.quantity.formatted(),
                    x: quantityX,
                    y: y,
                    width: contentWidth * 0.12,
                    font: regularFont.withSize(10),
                    alignment: .right
                )

                drawText(
                    item.unitPrice.formatted(
                        .number.precision(.fractionLength(2))
                    ),
                    x: priceX,
                    y: y,
                    width: contentWidth * 0.10,
                    font: regularFont.withSize(10),
                    alignment: .right
                )

                drawText(
                    item.lineTotal.formatted(
                        .number.precision(.fractionLength(2))
                    ),
                    x: totalX,
                    y: y,
                    width: contentWidth * 0.12,
                    font: regularFont.withSize(10),
                    alignment: .right
                )

                y += 28
            }

            let summaryY = max(y + 25, 370)

            drawLine(y: summaryY)

            drawText(
                "Subtotal: \(invoice.subtotal.formatted(.currency(code: "USD")))",
                x: margin,
                y: summaryY + 15,
                width: contentWidth,
                font: regularFont,
                alignment: .right
            )

            drawText(
                "Tax (\(invoice.taxRate.formatted())%): \(invoice.taxAmount.formatted(.currency(code: "USD")))",
                x: margin,
                y: summaryY + 38,
                width: contentWidth,
                font: regularFont,
                alignment: .right
            )

            drawText(
                "TOTAL: \(invoice.total.formatted(.currency(code: "USD")))",
                x: margin,
                y: summaryY + 68,
                width: contentWidth,
                font: boldFont.withSize(18),
                color: .systemBlue,
                alignment: .right
            )

            drawText(
                "Payment terms: \(invoice.paymentTerms)",
                x: margin,
                y: summaryY + 115,
                width: contentWidth,
                font: regularFont.withSize(11)
            )

            drawText(
                "Thank you for your business.",
                x: margin,
                y: pageRect.height - 55,
                width: contentWidth,
                font: italicFont.withSize(10),
                color: .gray,
                alignment: .center
            )
        }

        let safeNumber = invoice.invoiceNumber.replacingOccurrences(
            of: "/",
            with: "-"
        )

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(safeNumber).pdf")

        try data.write(to: url, options: .atomic)

        return url
    }
}//
//  PDFGenerator.swift
//  SmartInvoice
//
//  Created by Muhammad Ahmad on 2026-10-14.
//
