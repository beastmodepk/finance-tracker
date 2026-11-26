import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject var store: Store
    @State private var search = ""
    @State private var filter = "All"          // All, Spending, Income, Pending
    @State private var categoryFilter: String? = nil
    @State private var showAdd = false
    @State private var confirmedIDs: Set<UUID> = []

    private let filters = ["All", "Spending", "Income", "Pending"]
    private var categories: [String] {
        Array(Set(store.transactions.map { $0.category })).sorted()
    }

    private var visible: [Transaction] {
        store.transactions.filter { tx in
            if !search.isEmpty && !tx.description.localizedCaseInsensitiveContains(search) { return false }
            if let categoryFilter, tx.category != categoryFilter { return false }
            switch filter {
            case "Spending": return tx.amount < 0
            case "Income": return tx.amount > 0
            case "Pending": return tx.isPending
            default: return true
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                Picker("Filter", selection: $filter) {
                    ForEach(filters, id: \.self) { Text($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        chip("All categories", selected: categoryFilter == nil) { categoryFilter = nil }
                        ForEach(categories, id: \.self) { category in
                            chip(category, selected: categoryFilter == category) { categoryFilter = category }
                        }
                    }
                    .padding(.horizontal)
                }

                List(visible) { tx in
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(tx.description).font(.subheadline).bold()
                            Spacer()
                            Text(money(tx.amount, signed: tx.amount > 0))
                                .font(.subheadline).bold()
                                .foregroundStyle(tx.amount > 0 ? Color.ftTeal : .primary)
                        }
                        HStack(spacing: 6) {
                            Text(tx.date.shortDay).font(.caption).foregroundStyle(.secondary)
                            Text(tx.category)
                                .font(.caption).bold()
                                .padding(.horizontal, 6).padding(.vertical, 1)
                                .background(Color.ftTealSoft).clipShape(Capsule())
                            if tx.isAutoCategorized {
                                Text("Auto").font(.caption).foregroundStyle(Color.ftTealDeep)
                            }
                            if tx.isSplit {
                                Text("Split").font(.caption).bold()
                                    .padding(.horizontal, 6).padding(.vertical, 1)
                                    .background(Color.ftAmberSoft).clipShape(Capsule())
                            }
                            if tx.isPending {
                                Text("Pending").font(.caption).bold()
                                    .padding(.horizontal, 6).padding(.vertical, 1)
                                    .background(Color.ftAmberSoft).clipShape(Capsule())
                            }
                            if tx.isRecurring {
                                Label("Recurring", systemImage: "repeat").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        // Auto-categorisation prompts to confirm — never silent.
                        if tx.needsCategoryConfirm && !confirmedIDs.contains(tx.id) {
                            HStack(spacing: 8) {
                                Text("Confirm category “\(tx.category)”?")
                                    .font(.caption).foregroundStyle(.secondary)
                                Button("Confirm") { confirmedIDs.insert(tx.id) }
                                    .font(.caption).bold()
                                Button("Change") { confirmedIDs.insert(tx.id) }
                                    .font(.caption)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Transactions")
            .searchable(text: $search, prompt: "Search payee, amount, tag…")
            .toolbar {
                Button { showAdd = true } label: { Label("Add", systemImage: "plus") }
            }
            .sheet(isPresented: $showAdd) { AddTransactionView() }
        }
    }

    private func chip(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption).bold()
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(selected ? Color.ftTealDeep : Color.ftCream)
                .foregroundStyle(selected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

struct AddTransactionView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var description = ""
    @State private var amountText = ""
    @State private var category = "Groceries"
    @State private var isIncome = false

    private let categoryOptions = ["Groceries", "Dining", "Transport", "Shopping", "Bills", "Gifts", "Income", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                TextField("Description", text: $description)
                TextField("Amount", text: $amountText)
                    .keyboardType(.decimalPad)
                Toggle("Income (money in)", isOn: $isIncome)
                Picker("Category", selection: $category) {
                    ForEach(categoryOptions, id: \.self) { Text($0) }
                }
            }
            .navigationTitle("Add transaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let value = Double(amountText) ?? 0
                        guard value != 0, !description.isEmpty else { return }
                        store.transactions.insert(
                            Transaction(date: Date(), description: description,
                                        category: isIncome ? "Income" : category,
                                        amount: isIncome ? abs(value) : -abs(value)),
                            at: 0)
                        dismiss()
                    }
                }
            }
        }
    }
}
