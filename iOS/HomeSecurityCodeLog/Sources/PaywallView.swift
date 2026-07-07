import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Theme.accent)
                    .padding(.top, 40)

                Text("Unlock Pro")
                    .font(Theme.titleFont)
                    .foregroundColor(Theme.textPrimary)

                Text("Unlimited codes, access-history notes, and code-rotation reminders")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                if let product = purchaseManager.product {
                    Button {
                        Task {
                            await purchaseManager.purchase()
                            store.isPro = purchaseManager.isPro
                            if purchaseManager.isPro { dismiss() }
                        }
                    } label: {
                        Text("Unlock for \(product.displayPrice) (one-time)")
                            .font(Theme.headlineFont)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .cornerRadius(14)
                    }
                    .accessibilityIdentifier("paywallPurchaseButton")
                    .padding(.horizontal, 24)
                } else {
                    ProgressView()
                }

                Button("Restore Purchases") {
                    Task {
                        await purchaseManager.restore()
                        store.isPro = purchaseManager.isPro
                        if purchaseManager.isPro { dismiss() }
                    }
                }
                .accessibilityIdentifier("restorePurchasesButton")
                .foregroundColor(Theme.textSecondary)

                Spacer()

                Button("Not now") { dismiss() }
                    .accessibilityIdentifier("paywallDismissButton")
                    .foregroundColor(Theme.textSecondary)
                    .padding(.bottom, 24)
            }
        }
    }
}
