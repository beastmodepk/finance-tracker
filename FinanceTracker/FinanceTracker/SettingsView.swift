import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @State private var confirmWipe = false
    @State private var confirmPlainExport = false

    var body: some View {
        List {
            Section("Vault") {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(store.isDemoMode ? "Demo vault (in-memory)" : "Unlocked (in-memory)")
                        .foregroundStyle(.secondary)
                }
                Button("Lock now") { store.lock() }
                Text("Honest status: this UI build keeps the vault in memory only. Real encrypted persistence (AES-256-GCM + PBKDF2) lands next — until then, closing the app clears demo data and nothing is stored on disk.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Your data") {
                Button("Export encrypted backup") { }
                Text("Encrypted backup export lands with encrypted persistence (next). One password-encrypted file will hold your whole vault.")
                    .font(.caption).foregroundStyle(.secondary)
                Button("Export plain CSV / JSON") { confirmPlainExport = true }
                Text("Plain exports are NOT encrypted — anyone with the file can read your finances.")
                    .font(.caption).foregroundStyle(Color.ftAmber)
            }
            Section("For testers") {
                HStack {
                    Text("Demo passphrase")
                    Spacer()
                    Text("Demo1234!").bold()
                }
                Text("Testers: open the demo vault with this passphrase, or tap “Open demo vault” on the lock screen. No account or bank login exists.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Promises") {
                Text("No account · No bank login · No server · No analytics · Data Not Collected (App Store privacy label). Bank sync is off by design — import is by file, on-device.")
                    .font(.subheadline)
            }
            Section("Danger zone") {
                Button("Wipe vault…", role: .destructive) { confirmWipe = true }
                Text("Deletes everything on this device and locks the app. Backups you exported are unaffected.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings & Privacy")
        .alert("Wipe this vault?", isPresented: $confirmWipe) {
            Button("Cancel", role: .cancel) { }
            Button("Wipe everything", role: .destructive) { store.wipeVault() }
        } message: {
            Text("This deletes all accounts, transactions, budgets and goals on this device. There is no undo.")
        }
        .alert("Export unencrypted data?", isPresented: $confirmPlainExport) {
            Button("Cancel", role: .cancel) { }
            Button("I understand", role: .destructive) { }
        } message: {
            Text("A plain CSV/JSON file can be read by anyone who gets it. Prefer the encrypted backup when it lands.")
        }
    }
}
