import SwiftUI

struct AccountsView: View {
    @EnvironmentObject var store: Store
    @State private var showAdd = false
    @State private var editing: Account? = nil

    var body: some View {
        NavigationStack {
            Group {
                if store.accounts.isEmpty {
                    ContentUnavailableView {
                        Label("No accounts yet", systemImage: "building.columns")
                    } description: {
                        Text("Add your bank accounts, cards and cash to start tracking. Everything stays on this phone — no bank login, ever.")
                    } actions: {
                        VStack(spacing: 10) {
                            Button("Add your first account") { showAdd = true }
                                .buttonStyle(.borderedProminent)
                                .tint(Color.ftTeal)
                            if store.isDemoMode || !store.budgets.isEmpty || !store.goals.isEmpty || !store.recurring.isEmpty {
                                Button("Start fresh — clear everything") { store.startFresh() }
                                    .font(.footnote)
                            }
                        }
                    }
                } else {
                    accountList
                }
            }
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAdd = true } label: { Label("Add account", systemImage: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) { AccountFormView(existing: nil) }
            .sheet(item: $editing) { account in AccountFormView(existing: account) }
        }
    }

    private var accountList: some View {
        List {
            Section {
                HStack {
                    Text("Net worth").bold()
                    Spacer()
                    Text(money(store.netWorth)).font(.title3).bold().foregroundStyle(Color.ftTealText)
                }
            }
            ForEach(store.accounts) { account in
                Button { editing = account } label: {
                    accountRow(account)
                }
                .buttonStyle(.plain)
            }
            .onDelete { offsets in
                store.accounts.remove(atOffsets: offsets)
            }
            if store.accounts.contains(where: { $0.balance < 0 }) {
                Section {
                    NavigationLink { DebtPayoffView() } label: {
                        Label("Debt payoff planner", systemImage: "chart.line.downtrend.xyaxis")
                    }
                }
            }
            Section {
                Text("Tap an account to edit it. Swipe left to delete.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private func accountRow(_ account: Account) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: icon(for: account.kind)).foregroundStyle(Color.ftTealText)
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
                if let apr = account.apr {
                    Text(String(format: "APR %.2f%%", apr)).font(.caption).foregroundStyle(.secondary)
                }
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
        .contentShape(Rectangle())
    }

    private func icon(for kind: String) -> String {
        switch kind {
        case "Checking": return "building.columns"
        case "Savings": return "piggybank"
        case "Credit Card": return "creditcard"
        case "Investment": return "chart.line.uptrend.xyaxis"
        case "Cash": return "banknote"
        case "Loan": return "banknote"
        default: return "wallet.bifold"
        }
    }
}

/// Add / edit form for one account. Used for both creating a new account
/// and editing an existing one (prefilled when `existing` is non-nil).
struct AccountFormView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    let existing: Account?
    @State private var name: String
    @State private var kind: String
    @State private var balanceText: String
    @State private var creditLimitText: String
    @State private var statementText: String
    @State private var minimumDueText: String
    @State private var dueDay: Int
    @State private var aprText: String

    static let kinds = ["Checking", "Savings", "Credit Card", "Cash", "Investment", "Loan"]

    init(existing: Account?) {
        self.existing = existing
        _name = State(initialValue: existing?.name ?? "")
        _kind = State(initialValue: existing?.kind ?? "Checking")
        if let existing, existing.kind == "Credit Card" {
            // For cards the form works in "amount owed" (positive).
            _balanceText = State(initialValue: String(format: "%.2f", abs(existing.balance)))
        } else if let existing {
            _balanceText = State(initialValue: String(format: "%.2f", existing.balance))
        } else {
            _balanceText = State(initialValue: "")
        }
        _creditLimitText = State(initialValue: existing?.creditLimit.map { String(format: "%.2f", $0) } ?? "")
        _statementText = State(initialValue: existing?.statementBalance.map { String(format: "%.2f", $0) } ?? "")
        _minimumDueText = State(initialValue: existing?.minimumDue.map { String(format: "%.2f", $0) } ?? "")
        _dueDay = State(initialValue: existing?.dueDay ?? 1)
        _aprText = State(initialValue: existing?.apr.map { String(format: "%.2f", $0) } ?? "")
    }

    private var isCard: Bool { kind == "Credit Card" }
    private var isDebt: Bool { kind == "Credit Card" || kind == "Loan" }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Account name", text: $name)
                Picker("Type", selection: $kind) {
                    ForEach(Self.kinds, id: \.self) { Text($0) }
                }
                TextField(isCard ? "Amount owed" : "Current balance", text: $balanceText)
                    .keyboardType(.decimalPad)
                if isCard {
                    TextField("Credit limit", text: $creditLimitText)
                        .keyboardType(.decimalPad)
                    TextField("Statement balance (blank = amount owed)", text: $statementText)
                        .keyboardType(.decimalPad)
                    TextField("Minimum due", text: $minimumDueText)
                        .keyboardType(.decimalPad)
                    Stepper("Payment due day: \(dueDay)", value: $dueDay, in: 1...28)
                    Text("Card balances are stored as money owed. Statement details are entered by you — no bank login, by design.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                if isDebt {
                    TextField("APR % (for the debt payoff planner)", text: $aprText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle(existing == nil ? "Add account" : "Edit account")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let entered = Double(balanceText) ?? 0
        let balance = isCard ? -abs(entered) : entered
        let statement: Double? = isCard ? (Double(statementText) ?? abs(entered)) : nil
        let minimum: Double? = isCard ? Double(minimumDueText) : nil
        let limit: Double? = isCard ? Double(creditLimitText) : nil
        let apr: Double? = isDebt ? Double(aprText) : nil
        if let existing {
            if let idx = store.accounts.firstIndex(where: { $0.id == existing.id }) {
                store.accounts[idx].name = name
                store.accounts[idx].kind = kind
                store.accounts[idx].balance = balance
                store.accounts[idx].statementBalance = statement
                store.accounts[idx].minimumDue = minimum
                store.accounts[idx].dueDay = isCard ? dueDay : nil
                store.accounts[idx].creditLimit = limit
                store.accounts[idx].apr = apr
            }
        } else {
            // Memberwise init order (Models.swift): name, kind, balance,
            // statementBalance, minimumDue, dueDay, creditLimit, note, apr.
            store.accounts.append(Account(name: name, kind: kind, balance: balance,
                                          statementBalance: statement, minimumDue: minimum,
                                          dueDay: isCard ? dueDay : nil, creditLimit: limit,
                                          apr: apr))
        }
        dismiss()
    }
}
