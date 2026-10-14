import SwiftUI

struct OverviewView: View {
    let onSkip: () -> Void
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "doc.text.fill")
                    .foregroundStyle(.blue)

                Text("FastInvoice")
                    .font(AppFont.style(.headline, weight: .bold))

                Spacer()

                Button("Skip", action: onSkip)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 12)

            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.12),
                                Color.cyan.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 250)

                VStack(spacing: 14) {
                    Image(systemName: "doc.richtext.fill")
                        .font(.system(size: 66))
                        .foregroundStyle(.blue)

                    HStack(spacing: 8) {
                        featureIcon("checkmark.circle.fill")
                        featureIcon("square.and.arrow.up.fill")
                        featureIcon("bolt.fill")
                    }
                }
            }

            Spacer().frame(height: 34)

            Text("Invoicing made simple.")
                .font(AppFont.custom(size: 32, weight: .bold, relativeTo: .largeTitle))
                .foregroundStyle(Color(red: 0.10, green: 0.15, blue: 0.25))
                .fixedSize(horizontal: false, vertical: true)

            Text("Create professional invoices in seconds. Keep your work organized and send polished PDFs to your clients.")
                .font(AppFont.custom(size: 16))
                .foregroundStyle(.secondary)
                .lineSpacing(5)
                .padding(.top, 12)

            VStack(alignment: .leading, spacing: 18) {
                overviewFeature(
                    icon: "clock.fill",
                    title: "Save time",
                    subtitle: "Create invoices without the busywork."
                )

                overviewFeature(
                    icon: "doc.text.fill",
                    title: "Professional PDFs",
                    subtitle: "Export and share invoices with clients."
                )

                overviewFeature(
                    icon: "iphone",
                    title: "Your invoices, on your device",
                    subtitle: "Keep your invoices available locally."
                )
            }
            .padding(.top, 28)

            Spacer()

            Button(action: onContinue) {
                HStack {
                    Text("Continue")
                        .font(AppFont.custom(size: 17, weight: .semibold))
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding()
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 24)
    }

    private func featureIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.blue)
            .frame(width: 42, height: 42)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 13))
    }

    private func overviewFeature(
        icon: String,
        title: String,
        subtitle: String
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 46, height: 46)
                .background(Color.blue.opacity(0.09))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppFont.custom(size: 15, weight: .semibold))

                Text(subtitle)
                    .font(AppFont.custom(size: 13))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
