import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @State private var confirmWipe = false
    @State private var confirmPlainExport = false
    @State private var confirmStartFresh = false

    var body: some View {
        List {
            Section("Vault") {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(store.isDemoMode ? "Demo vault (saved on device)" : "Saved on this device")
                        .foregroundStyle(.secondary)
                }
                Button("Lock now") { store.lock() }
                Text("Honest status: your data is saved on this device only, in a data file that is NOT encrypted yet, so it survives closing the app. Real encrypted persistence (AES-256-GCM + PBKDF2) lands in the vault pass. Nothing leaves this phone — no server, no analytics.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Your data") {
                Button("Start fresh — clear demo & enter my own data…") { confirmStartFresh = true }
                Text("Removes everything currently in the app (including the demo data) and saves the empty state, so you can add only your own real accounts, budgets and goals.")
                    .font(.caption).foregroundStyle(.secondary)
                Button("Export encrypted backup") { }
                Text("Encrypted backup export lands with the encrypted vault pass. One password-encrypted file will hold your whole vault.")
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
        .alert("Start fresh?", isPresented: $confirmStartFresh) {
            Button("Cancel", role: .cancel) { }
            Button("Clear everything", role: .destructive) { store.startFresh() }
        } message: {
            Text("This clears all accounts, transactions, budgets, goals and recurring items currently in the app and saves the empty state. There is no undo.")
        }
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
