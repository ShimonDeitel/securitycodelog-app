import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchaseManager: PurchaseManager
    @Environment(\.dismiss) var dismiss
    @AppStorage("securitycodelog_showDates") private var showDates = true
    @AppStorage("securitycodelog_showNotes") private var showNotes = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Display") {
                    Toggle("Show dates", isOn: $showDates)
                        .accessibilityIdentifier("toggleShowDates")
                    Toggle("Show notes", isOn: $showNotes)
                        .accessibilityIdentifier("toggleShowNotes")
                }
                Section("Pro") {
                    if purchaseManager.isPro {
                        Label("Pro unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundColor(Theme.accent)
                    } else {
                        Button("Unlock Pro") {
                            dismiss()
                        }
                        .accessibilityIdentifier("unlockProButton")
                    }
                    Button("Restore Purchases") {
                        Task {
                            await purchaseManager.restore()
                            store.isPro = purchaseManager.isPro
                        }
                    }
                    .accessibilityIdentifier("settingsRestoreButton")
                }
                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/securitycodelog-app/privacy.html")!)
                    Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/securitycodelog-app/terms.html")!)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("settingsDoneButton")
                }
            }
        }
    }
}
