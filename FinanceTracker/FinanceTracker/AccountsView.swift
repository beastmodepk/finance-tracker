import SwiftUI

struct AccountsView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Net worth").bold()
                        Spacer()
                        Text(money(store.netWorth)).font(.title3).bold().foregroundStyle(Color.ftTealDeep)
                    }
                }
                ForEach(store.accounts) { account in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: icon(for: account.kind)).foregroundStyle(Color.ftTealDeep)
                            Text(account.name).bold()
                            Spacer()
                            Text(money(account.balance))
                                .bold()
                                .foregroundStyle(account.balance < 0 ? .red : .primary)
                        }
                        Text(account.kind).font(.caption).foregroundStyle(.secondary)
                        if account.kind == "Credit Card",
                           let statement = account.statementBalance,
                           let minimum = account.minimumDue {
                            Text("Statement balance \(money(statement)) · Minimum due \(money(minimum)) · Due day \(account.dueDay ?? 0) of the month")
                                .font(.caption)
                            if let utilisation = account.utilisation {
                                ProgressView(value: utilisation)
                                    .tint(Color.ftAmber)
                                Text("\(Int(utilisation * 100))% of \(money(account.creditLimit ?? 0)) limit used")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Text("Statement details entered by you / read from a statement file — no bank login, by design.")
                                .font(.caption).foregroundStyle(.tertiary)
                        }
                        if let note = account.note {
                            Text(note).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .navigationTitle("Accounts")
        }
    }

    private func icon(for kind: String) -> String {
        switch kind {
        case "Checking": return "building.columns"
        case "Savings": return "piggybank"
        case "Credit Card": return "creditcard"
        case "Investment": return "chart.line.uptrend.xyaxis"
        case "Cash": return "banknote"
        default: return "wallet.bifold"
        }
    }
}
