import SwiftUI

struct GetStartedView: View {
    let onBack: () -> Void
    let onGetStarted: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .background(.white)
                        .clipShape(Circle())
                }

                Spacer()

                Text("GET STARTED")
                    .font(AppFont.custom(size: 12, weight: .bold, relativeTo: .caption))
                    .tracking(2)
                    .foregroundStyle(.secondary)

                Spacer()

                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.top, 12)

            Spacer()

            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.08))
                    .frame(width: 230, height: 230)

                Circle()
                    .fill(Color.blue.opacity(0.08))
                    .frame(width: 175, height: 175)

                Image(systemName: "doc.text.fill")
                    .font(.system(size: 76))
                    .foregroundStyle(.blue)

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(.green)
                    .background(Circle().fill(.white).padding(-5))
                    .offset(x: 76, y: 66)
            }

            Spacer().frame(height: 42)

            Text("Ready to get paid?")
                .font(AppFont.custom(size: 32, weight: .bold, relativeTo: .largeTitle))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(red: 0.10, green: 0.15, blue: 0.25))

            Text("Start creating clear, professional invoices for your freelance work and business.")
                .font(AppFont.custom(size: 16))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.top, 14)
                .padding(.horizontal, 12)

            VStack(alignment: .leading, spacing: 16) {
                benefitRow("Create invoices with multiple line items")
                benefitRow("Calculate totals and tax automatically")
                benefitRow("Generate PDFs and share them easily")
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.top, 30)

            Spacer()

            Button(action: onGetStarted) {
                HStack {
                    Text("Get Started")
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

            Text("Simple invoicing, right from your iPhone.")
                .font(AppFont.custom(size: 12, relativeTo: .caption))
                .foregroundStyle(.secondary)
                .padding(.top, 14)
                .padding(.bottom, 12)
        }
        .padding(.horizontal, 24)
    }

    private func benefitRow(_ title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 19))
                .foregroundStyle(.green)

            Text(title)
                .font(AppFont.custom(size: 14, weight: .medium))
                .foregroundStyle(.primary)
        }
    }
}
