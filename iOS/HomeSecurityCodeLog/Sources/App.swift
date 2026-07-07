import SwiftUI

@main
struct HomeSecurityCodeLogApp: App {
    @StateObject private var store = Store()
    @StateObject private var purchaseManager = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(purchaseManager)
                .onChange(of: purchaseManager.isPro) { _, newValue in
                    store.isPro = newValue
                }
                .onAppear {
                    store.isPro = purchaseManager.isPro
                }
        }
    }
}
