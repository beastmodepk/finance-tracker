import SwiftUI

struct BudgetsView: View {
    @EnvironmentObject var store: Store
    @State private var showAdd = false
    @State private var editing: Budget? = nil

    var body: some View {
        List {
            Section {
                if store.budgets.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("No budgets yet.").bold()
                        Text("Add one per category you want to keep an eye on.")
                            .font(.caption).foregroundStyle(.secondary)
                        Button("Add your first budget") { showAdd = true }
                            .buttonStyle(.borderedProminent).tint(Color.ftTeal)
                    }
                }
                ForEach(store.budgets) { budget in
                    Button { editing = budget } label: {
                        budgetRow(budget)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { offsets in
                    store.budgets.remove(atOffsets: offsets)
                }
            } header: {
                Text("Budgets")
            } footer: {
                Text("Tap a budget to edit it. Swipe left to delete.")
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showAdd = true } label: { Label("Add budget", systemImage: "plus") }
            }
        }
        .sheet(isPresented: $showAdd) { BudgetFormView(existing: nil) }
        .sheet(item: $editing) { budget in BudgetFormView(existing: budget) }
    }

    private func budgetRow(_ budget: Budget) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(budget.category).bold()
                Spacer()
                Text("\(money(budget.spent)) / \(money(budget.limit))")
                    .foregroundStyle(budget.spent > budget.limit ? .red : .primary)
            }
            ProgressView(value: min(budget.spent, budget.limit), total: max(budget.limit, 1))
                .tint(budget.spent > budget.limit ? .red : Color.ftTeal)
            if budget.spent > budget.limit {
                Text("Over by \(money(budget.spent - budget.limit)) — rollover is \(budget.rollover ? "on" : "off") for this one")
                    .font(.caption).foregroundStyle(.red)
            } else {
                Text("\(money(budget.limit - budget.spent)) left")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }
}

/// Add / edit form for one budget.
struct BudgetFormView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    let existing: Budget?
    @State private var category: String
    @State private var limitText: String
    @State private var spentText: String
    @State private var rollover: Bool

    init(existing: Budget?) {
        self.existing = existing
        _category = State(initialValue: existing?.category ?? "")
        _limitText = State(initialValue: existing.map { String(format: "%.2f", $0.limit) } ?? "")
        _spentText = State(initialValue: existing.map { String(format: "%.2f", $0.spent) } ?? "0")
        _rollover = State(initialValue: existing?.rollover ?? false)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Category (e.g. Groceries)", text: $category)
                TextField("Monthly limit", text: $limitText)
                    .keyboardType(.decimalPad)
                TextField("Spent so far this month", text: $spentText)
                    .keyboardType(.decimalPad)
                Toggle("Roll leftover into next month", isOn: $rollover)
            }
            .navigationTitle(existing == nil ? "Add budget" : "Edit budget")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(category.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let limit = Double(limitText) ?? 0
        let spent = Double(spentText) ?? 0
        if let existing {
            if let idx = store.budgets.firstIndex(where: { $0.id == existing.id }) {
                store.budgets[idx].category = category
                store.budgets[idx].limit = limit
                store.budgets[idx].spent = spent
                store.budgets[idx].rollover = rollover
            }
        } else {
            // Memberwise init order (Models.swift): category, limit, spent, rollover.
            store.budgets.append(Budget(category: category, limit: limit, spent: spent, rollover: rollover))
        }
        dismiss()
    }
}
