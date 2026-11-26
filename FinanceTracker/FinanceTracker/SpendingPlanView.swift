import SwiftUI

struct SpendingPlanView: View {
    @EnvironmentObject var store: Store
    @State private var monthOffset = 0
    @State private var method = "Custom"
    @State private var showIncomeEdit = false

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
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Income (expected)")
                            Text(store.manualMonthlyIncome != nil ? "Set by you" : "From recurring income")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(money(store.expectedMonthlyIncome)).bold()
                        Button("Edit") { showIncomeEdit = true }
                            .buttonStyle(.bordered).tint(Color.ftTeal)
                    }
                    planRow("− Bills & subscriptions", money(store.monthlyBillsTotal))
                    planRow("− Savings goals", money(store.monthlyGoalContributions))
                    planRow("− Spent so far", money(store.spentThisMonth))
                    HStack {
                        Text("= Left to spend").bold()
                        Spacer()
                        Text(money(store.safeToSpend)).bold().foregroundStyle(Color.ftTealText).font(.title3)
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
            .sheet(isPresented: $showIncomeEdit) { IncomeFormView() }
        }
    }

    private func planRow(_ label: String, _ value: String) -> some View {
        HStack { Text(label); Spacer(); Text(value).bold() }
    }
}

/// Edit the expected monthly income used by the plan maths. Saving sets a
/// manual override on the store; clearing it falls back to the income
/// derived from recurring items.
struct IncomeFormView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var incomeText: String

    init() {
        _incomeText = State(initialValue: "")
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Expected monthly income", text: $incomeText)
                    .keyboardType(.decimalPad)
                Text("This is the income the Spending Plan and “safe to spend” are worked out from. Leave the maths to your recurring income instead by clearing the override.")
                    .font(.caption).foregroundStyle(.secondary)
                if store.manualMonthlyIncome != nil {
                    Button("Clear override — use recurring income", role: .destructive) {
                        store.manualMonthlyIncome = nil
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit income")
            .onAppear {
                if incomeText.isEmpty {
                    incomeText = String(format: "%.2f", store.expectedMonthlyIncome)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let value = Double(incomeText) {
                            store.manualMonthlyIncome = value
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}
