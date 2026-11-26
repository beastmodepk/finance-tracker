import SwiftUI

/// Vault gate (wireframe screen 1). UI gate only in this build:
/// data persists on-device unencrypted; real encryption lands in the
/// vault pass (see Settings).
struct VaultView: View {
    @EnvironmentObject var store: Store
    @State private var passphrase = ""
    @State private var showError = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.ftTealDeep)
                    .padding(.top, 32)
                Text("Your vault is locked")
                    .font(.title2).bold()
                Text("Everything stays on this phone.\nNo account. No server. No bank login.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                SecureField("Passphrase", text: $passphrase)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                if showError {
                    Text("That passphrase didn't work — check it and try again.")
                        .font(.footnote).foregroundStyle(.red)
                }
                Button {
                    if !store.unlock(passphrase: passphrase) { showError = true }
                } label: {
                    Text("Unlock vault")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.ftTeal)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Just looking?").bold()
                        Spacer()
                        Text("TEST")
                            .font(.caption).bold()
                            .padding(.horizontal, 8).padding(.vertical, 2)
                            .background(Color.ftAmberSoft).clipShape(Capsule())
                    }
                    Text("Open the demo vault — sample data, nothing real.")
                        .font(.subheadline).foregroundStyle(.secondary)
                    HStack {
                        Text("Demo passphrase").font(.subheadline).foregroundStyle(.secondary)
                        Spacer()
                        Text("Demo1234!").bold()
                    }
                    Button {
                        store.openDemoVault()
                    } label: {
                        Text("Open demo vault")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.ftAmber)
                }
                .padding()
                .background(Color.ftCream)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)

                Text("Forgot it? There is no reset — that's the point.\nRestore from your encrypted backup instead.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)
            }
        }
    }
}
