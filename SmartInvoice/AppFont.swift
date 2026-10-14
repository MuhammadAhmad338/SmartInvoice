import CoreText
import SwiftUI
import UIKit

enum GoogleSansFlexFont {
    static let familyName = "GoogleSansFlex-Regular"

    static func register() throws {
        guard let url = Bundle.main.url(
            forResource: "GoogleSansFlex",
            withExtension: "ttf"
        ) else {
            throw FontError.missingResource
        }

        var registrationError: Unmanaged<CFError>?
        guard CTFontManagerRegisterFontsForURL(
            url as CFURL,
            .process,
            &registrationError
        ) else {
            let message = registrationError?
                .takeRetainedValue()
                .localizedDescription ?? "Unknown font registration error."
            throw FontError.registrationFailed(message)
        }
    }

    private enum FontError: LocalizedError {
        case missingResource
        case registrationFailed(String)

        var errorDescription: String? {
            switch self {
            case .missingResource:
                return "GoogleSansFlex.ttf is missing from the app bundle."
            case .registrationFailed(let message):
                return "Google Sans Flex could not be registered: \(message)"
            }
        }
    }
}

enum AppFont {
    static func custom(
        size: CGFloat,
        weight: Font.Weight = .regular,
        relativeTo textStyle: Font.TextStyle = .body
    ) -> Font {
        .custom(
            GoogleSansFlexFont.familyName,
            size: size,
            relativeTo: textStyle
        )
        .weight(weight)
    }

    static func style(
        _ textStyle: Font.TextStyle,
        weight: Font.Weight = .regular
    ) -> Font {
        let size: CGFloat
        switch textStyle {
        case .largeTitle: size = 34
        case .title: size = 28
        case .title2: size = 22
        case .title3: size = 20
        case .headline: size = 17
        case .subheadline: size = 15
        case .callout: size = 16
        case .footnote: size = 13
        case .caption: size = 12
        case .caption2: size = 11
        default: size = 17
        }

        return custom(size: size, weight: weight, relativeTo: textStyle)
    }
}
