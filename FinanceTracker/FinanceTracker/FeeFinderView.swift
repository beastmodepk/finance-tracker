import SwiftUI

/// Fee finder: scans the ledger for bank fees and interest charges —
/// category "Fees", or fee-ish words in the description — and totals
/// them for this month and this year. Pure local scan, nothing leaves
/// the phone.
struct FeeFinderView: View {
    @EnvironmentObject var store: Store

    private static let keywords: Set<String> = [
        "fee", "fees", "interest", "charge", "charges", "atm",
        "late", "overdraft", "finance", "service",
    ]

    static func isFee(_ tx: Transaction) -> Bool {
        guard tx.amount < 0 else { return false }
        if tx.category.caseInsensitiveCompare("Fees") == .orderedSame { return true }
        // Word-boundary-ish: split the description into alphanumeric
        // tokens so "Fee" matches but "Coffee" doesn't.
        let tokens = tx.description.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
        return tokens.contains { keywords.contains($0) }
    }

    private var fees: [Transaction] {
        store.transactions.filter(Self.isFee).sorted { $0.date > $1.date }
    }
    private var thisMonth: Double {
        abs(fees.filter { $0.date.isThisMonth }.reduce(0) { $0 + $1.amount })
    }
    private var thisYear: Double {
        let year = Calendar.current.component(.year, from: Date())
        return abs(fees.filter { Calendar.current.component(.year, from: $0.date) == year }
            .reduce(0) { $0 + $1.amount })
    }

    var body: some View {
        Group {
            if fees.isEmpty {
                ContentUnavailableView {
                    Label("No fees found — nice.", systemImage: "checkmark.seal")
                } description: {
                    Text("We scan your transactions for bank fees and interest charges. None turned up — keep it that way.")
                }
            } else {
                List {
                    Section {
                        HStack {
                            Text("This month")
                            Spacer()
                            Text(money(thisMonth)).bold()
                        }
                        HStack {
                            Text("This year")
                            Spacer()
                            Text(money(thisYear)).bold()
                        }
                    }
                    .font(.subheadline)
                    Section("Charges found") {
                        ForEach(fees) { tx in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(tx.description)
                                    Text(tx.date.shortDay)
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(money(tx.amount)).bold()
                            }
                            .font(.subheadline)
                        }
                    }
                    Section {
                        Text("Fees are quiet money. If one looks wrong, dispute it with your bank — we only flag them, we never act on your accounts.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Fees & interest")
    }
}
