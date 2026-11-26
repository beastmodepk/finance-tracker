import SwiftUI

struct SpendingPlanView: View {
    @EnvironmentObject var store: Store
    @State private var monthOffset = 0
    @State private var method = "Custom"

    private let methods = ["Custom", "50/30/20", "Zero-based", "Envelope"]

    private var monthLabel: String {
        let date = Calendar.current.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: date)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Button { monthOffset -= 1 } label: { Image(systemName: "chevron.left") }
                        Spacer()
                        Text(monthLabel).bold()
                        Spacer()
                        Button { monthOffset += 1 } label: { Image(systemName: "chevron.right") }
                    }
                }
                Section("The maths") {
                    planRow("Income (expected)", money(store.expectedMonthlyIncome))
                    planRow("− Bills & subscriptions", money(store.monthlyBillsTotal))
                    planRow("− Savings goals", money(store.monthlyGoalContributions))
                    planRow("− Spent so far", money(store.spentThisMonth))
                    HStack {
                        Text("= Left to spend").bold()
                        Spacer()
                        Text(money(store.safeToSpend)).bold().foregroundStyle(Color.ftTealDeep).font(.title3)
                    }
                }
                Section("Method — display only, the maths doesn't change") {
                    Picker("Budget method", selection: $method) {
                        ForEach(methods, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Planned spending — rollover per budget") {
                    ForEach($store.budgets) { $budget in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("\(budget.category) · \(money(budget.limit)) plan")
                                Spacer()
                                Toggle("Rollover", isOn: $budget.rollover)
                                    .labelsHidden()
                            }
                            ProgressView(value: min(budget.spent, budget.limit), total: budget.limit)
                                .tint(budget.spent > budget.limit ? .red : Color.ftTeal)
                            Text("\(money(budget.spent)) spent · Rollover \(budget.rollover ? "on" : "off")")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Spending Plan")
        }
    }

    private func planRow(_ label: String, _ value: String) -> some View {
        HStack { Text(label); Spacer(); Text(value).bold() }
    }
}
