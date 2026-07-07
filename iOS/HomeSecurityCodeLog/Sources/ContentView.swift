import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingItem: HomeSecurityCodeLogItem?

    @State private var unlocked = false

    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock your codes") { success, _ in
                DispatchQueue.main.async { unlocked = success }
            }
        } else {
            unlocked = true
        }
    }

    var body: some View {

        Group {
            if unlocked {

        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(store.items) { item in
                            row(for: item)
                                .listRowBackground(Theme.background)
                                .contentShape(Rectangle())
                                .onTapGesture { editingItem = item }
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Theme.background)
                }
            }
            .navigationTitle("Home Security Code Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                    .foregroundColor(Theme.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                    .foregroundColor(Theme.accent)
                }
            }
            .sheet(isPresented: $showingAdd) {
                EditItemView(item: nil)
            }
            .sheet(item: $editingItem) { item in
                EditItemView(item: item)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)

            } else {
                lockScreen
            }
        }
        .onAppear { if !unlocked { authenticate() } }

    }

    private func row(for item: HomeSecurityCodeLogItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.codeName)
                .font(Theme.headlineFont)
                .foregroundColor(Theme.textPrimary)
            Text(item.codeValue)
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textSecondary)
            Text(item.notes)
                .font(Theme.captionFont)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(.vertical, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(Theme.accent)
            Text("No Codes yet")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.textPrimary)
            Text("Tap + to add your first one.")
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textSecondary)
        }
    }

    private var lockScreen: some View {
        VStack(spacing: 16) {
            Image(systemName: "faceid")
                .font(.system(size: 44))
                .foregroundColor(Theme.accent)
            Text("Locked")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.textPrimary)
            Button("Unlock") { authenticate() }
                .accessibilityIdentifier("unlockButton")
                .foregroundColor(Theme.accent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background.ignoresSafeArea())
    }

}

struct EditItemView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    var item: HomeSecurityCodeLogItem?

    @State private var codeName: String = ""
    @State private var codeValue: String = ""
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Code Name") {
                    TextField("Code Name", text: $codeName)
                        .accessibilityIdentifier("fieldCodeName")
                }
                Section("Code Value") {
                    TextField("Code Value", text: $codeValue)
                        .accessibilityIdentifier("fieldCodeValue")
                }
                Section("Notes") {
                    TextField("Notes", text: $notes)
                        .accessibilityIdentifier("fieldNotes")
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle(item == nil ? "Add Code" : "Edit Code")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("saveButton")
                    .disabled(codeName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let item {
                    codeName = item.codeName
                    codeValue = item.codeValue
                    notes = item.notes
                }
            }
        }
    }

    private func save() {
        if var existing = item {
            existing.codeName = codeName
            existing.codeValue = codeValue
            existing.notes = notes
            store.update(existing)
        } else {
            let newItem = HomeSecurityCodeLogItem(codeName: codeName, codeValue: codeValue, notes: notes)
            store.add(newItem)
        }
        dismiss()
    }
}
