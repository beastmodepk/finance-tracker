import SwiftUI

struct BudgetsView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        List {
            Section("Budgets") {
                ForEach(store.budgets) { budget in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(budget.category).bold()
                            Spacer()
                            Text("\(money(budget.spent)) / \(money(budget.limit))")
                                .foregroundStyle(budget.spent > budget.limit ? .red : .primary)
                        }
                        ProgressView(value: min(budget.spent, budget.limit), total: budget.limit)
                            .tint(budget.spent > budget.limit ? .red : Color.ftTeal)
                        if budget.spent > budget.limit {
                            Text("Over by \(money(budget.spent - budget.limit)) — rollover is \(budget.rollover ? "on" : "off") for this one")
                                .font(.caption).foregroundStyle(.red)
                        } else {
                            Text("\(money(budget.limit - budget.spent)) left")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            Section {
                Text("Track without a hard budget — a nudge, not a limit.")
                    .font(.caption).foregroundStyle(.secondary)
                ForEach(store.watchlists) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("\(item.kind): \(item.label)").bold()
                            Spacer()
                            Text(money(item.spent)).bold()
                        }
                        if let alertAt = item.alertAt {
                            ProgressView(value: min(item.spent, alertAt), total: alertAt)
                                .tint(Color.ftAmber)
                            Text("Alert at \(money(alertAt))/mo")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        if !item.detail.isEmpty {
                            Text(item.detail).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text("Watchlists")
            }
        }
        .navigationTitle("Budgets & Watchlists")
    }
}
