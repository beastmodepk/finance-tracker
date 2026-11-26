import SwiftUI

/// Migration wizard (wireframe screen 10). One scrolling flow.
/// File reading itself lands next — the picker button says so honestly.
struct ImportView: View {
    @EnvironmentObject var store: Store
    @State private var source = "Simplifi"
    @State private var skipDuplicates = true
    @State private var showFileNote = false

    // Owner default: Other App and Bank File shown equally;
    // Simplifi listed first among the apps.
    private let appSources = ["Simplifi", "Monarch", "YNAB", "Copilot", "Rocket Money"]
    private let bankSources = ["Bank CSV", "Bank OFX/QFX"]

    private var instructions: String {
        switch source {
        case "Simplifi":
            return "In Simplifi's web app (export is web-only, CSV only): Transactions → Export / Download CSV. Repeat per account if prompted."
        case "Monarch":
            return "In Monarch on the web: Settings → Data → Download transactions for a full CSV. Split long histories at ~5,000 rows per file; dedupe here handles overlaps."
        case "YNAB":
            return "In YNAB on the web: click your plan name → Export Plan, then import the transactions CSV. Note: YNAB targets and category notes do not export."
        case "Copilot":
            return "On iPhone: Settings → Account → Export your transactions (full CSV, save to Files). On Mac/web, export the filtered Transactions view instead."
        case "Rocket Money":
            return "Rocket Money has no full-history CSV export. Workaround: download transactions from each underlying bank instead, and import those files here."
        case "Bank OFX/QFX":
            return "On your bank's website: account → Download account activity → choose Quicken/OFX (QFX) format. OFX/QFX files map themselves — no column mapping needed."
        default:
            return "On your bank's website (Chase, Bank of America, Wells Fargo, Citi all offer this): account → Download transactions → CSV, one account at a time."
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Files are read on this phone only. Nothing is uploaded, ever.")
                    .font(.subheadline).foregroundStyle(.secondary)

                GroupBox("Step 1 · Where from?") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("From another app").font(.caption).bold().foregroundStyle(.secondary)
                        sourceChips(appSources)
                        Text("From your bank").font(.caption).bold().foregroundStyle(.secondary)
                        sourceChips(bankSources)
                        Text(instructions).font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                GroupBox("Step 2 · File & account") {
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            showFileNote = true
                        } label: {
                            Label("Choose a file…", systemImage: "doc.badge.plus")
                        }
                        if showFileNote {
                            Text("File reading lands in the next build — this wizard's flow, mapping and dedupe are ready for it.")
                                .font(.caption).foregroundStyle(Color.ftAmberText)
                        }
                        Text("Into account: \(store.accounts.first?.name ?? "Checking")")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                GroupBox("Step 3 · Map columns (CSV preview)") {
                    VStack(alignment: .leading, spacing: 4) {
                        mapRow("Date", "Date ✓ auto")
                        mapRow("Payee", "Description ✓")
                        mapRow("Amount", "Amount ✓")
                        mapRow("Category", "Category ✓")
                        Text("OFX/QFX files skip this step — they map themselves.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                GroupBox("Step 4 · Preview & dedupe") {
                    VStack(alignment: .leading, spacing: 6) {
                        Toggle("Skip likely duplicates (same date + amount + payee)", isOn: $skipDuplicates)
                            .font(.subheadline)
                        Text("Duplicates are skipped by default. Every row is shown before anything is saved, and unreadable rows are flagged with the reason.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                GroupBox("Step 5 · Finish your move") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("☐ All accounts created, balances checked")
                        Text("☐ History imported per account")
                        Text("☐ Rebuild Spending Plan & goals")
                        Text("☐ Confirm recurring list, then export an encrypted backup")
                    }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .navigationTitle("Bring your data in")
    }

    private func sourceChips(_ options: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 6) {
            ForEach(options, id: \.self) { option in
                Button { source = option } label: {
                    Text(option)
                        .font(.caption).bold()
                        .padding(.horizontal, 9).padding(.vertical, 5)
                        .background(source == option ? Color.ftTealDeep : Color.ftSurface)
                        .foregroundStyle(source == option ? .white : .primary)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(source == option ? Color.clear : Color.secondary.opacity(0.35), lineWidth: 1)
                        )
                }
            }
        }
        }
    }

    private func mapRow(_ from: String, _ to: String) -> some View {
        HStack {
            Text(from).font(.caption)
            Spacer()
            Text("→ \(to)").font(.caption).foregroundStyle(.secondary)
        }
    }
}
