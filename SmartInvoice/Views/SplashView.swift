import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.blue)
                    .frame(width: 100, height: 100)

                Image(systemName: "doc.text.fill")
                    .font(.system(size: 46, weight: .medium))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 8) {
                Text("FastInvoice")
                    .font(AppFont.custom(size: 34, weight: .bold, relativeTo: .largeTitle))
                    .foregroundStyle(Color(red: 0.10, green: 0.15, blue: 0.25))

                Text("Professional invoices. Less effort.")
                    .font(AppFont.custom(size: 16, relativeTo: .body))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            ProgressView()
                .tint(.blue)
                .padding(.bottom, 50)
        }
    }
}
