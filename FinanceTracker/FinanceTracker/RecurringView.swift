import SwiftUI

struct RecurringView: View {
    @EnvironmentObject var store: Store
    @State private var showAdd = false
    @State private var editing: RecurringItem? = nil

    private var subscriptions: [RecurringItem] { store.recurring.filter { $0.isSubscription } }
    private var subscriptionMonthly: Double { abs(subscriptions.reduce(0) { $0 + $1.amount }) }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("COMMITTED EACH MONTH").font(.caption).bold().foregroundStyle(.white.opacity(0.75))
                    Text(money(store.monthlyBillsTotal)).font(.title).bold().foregroundStyle(.white)
                    Text("\(store.recurring.filter { $0.amount < 0 }.count) recurring charges")
                        .font(.caption).foregroundStyle(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .listRowBackground(Color.ftTealDeep)
            }
            Section("Upcoming") {
                if store.upcomingRecurring.isEmpty {
                    Text("Nothing scheduled.").font(.subheadline).foregroundStyle(.secondary)
                }
                ForEach(store.upcomingRecurring.prefix(6)) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Text("Day \(item.dayOfMonth) · \(money(abs(item.amount)))")
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
            }
            Section {
                if store.recurring.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("No bills or subscriptions yet.").bold()
                        Text("Add the things that hit every month — rent, phone, streaming — and the plan maths will use them.")
                            .font(.caption).foregroundStyle(.secondary)
                        Button("Add your first recurring item") { showAdd = true }
                            .buttonStyle(.borderedProminent).tint(Color.ftTeal)
                    }
                }
                ForEach(store.recurring) { item in
                    Button { editing = item } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                Text(item.amount > 0 ? "Income" : (item.isSubscription ? "Subscription" : "Bill"))
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(money(item.amount, signed: item.amount > 0)) · day \(item.dayOfMonth)")
                                .foregroundStyle(.secondary)
                        }
                        .font(.subheadline)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { offsets in
                    store.recurring.remove(atOffsets: offsets)
                }
            } header: {
                Text("All recurring")
            } footer: {
                Text("Tap an item to edit it. Swipe left to delete.")
            }
            Section("Subscription finder") {
                ForEach(subscriptions) { item in
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(item.name)
                            Spacer()
                            if item.priceRose, let previous = item.previousAmount {
                                Text("\(money(abs(previous))) → \(money(abs(item.amount)))").bold()
                            } else {
                                Text("\(money(abs(item.amount)))/mo").bold()
                            }
                        }
                        .font(.subheadline)
                        if item.priceRose {
                            Text("Price rose").font(.caption).bold().foregroundStyle(.red)
                        }
                        if item.looksUnused {
                            Text("Unused? No activity logged").font(.caption).bold().foregroundStyle(Color.ftAmber)
                        }
                    }
                }
                Text("Total subscriptions: \(money(subscriptionMonthly))/mo · \(money(subscriptionMonthly * 12))/yr. We flag them — cancelling happens in each provider's own app; we never act on your accounts.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Recurring")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showAdd = true } label: { Label("Add recurring", systemImage: "plus") }
            }
        }
        .sheet(isPresented: $showAdd) { RecurringFormView(existing: nil) }
        .sheet(item: $editing) { item in RecurringFormView(existing: item) }
    }
}

/// Add / edit form for one recurring bill, subscription or income.
struct RecurringFormView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    let existing: RecurringItem?
    @State private var name: String
    @State private var amountText: String
    @State private var dayOfMonth: Int
    @State private var kind: String   // "Bill", "Subscription", "Income"

    static let kinds = ["Bill", "Subscription", "Income"]

    init(existing: RecurringItem?) {
        self.existing = existing
        _name = State(initialValue: existing?.name ?? "")
        _amountText = State(initialValue: existing.map { String(format: "%.2f", abs($0.amount)) } ?? "")
        _dayOfMonth = State(initialValue: existing?.dayOfMonth ?? 1)
        if let existing {
            _kind = State(initialValue: existing.amount > 0 ? "Income" : (existing.isSubscription ? "Subscription" : "Bill"))
        } else {
            _kind = State(initialValue: "Bill")
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                Picker("Type", selection: $kind) {
                    ForEach(Self.kinds, id: \.self) { Text($0) }
                }
                .pickerStyle(.segmented)
                TextField("Amount (per month)", text: $amountText)
                    .keyboardType(.decimalPad)
                Stepper("Day of month: \(dayOfMonth)", value: $dayOfMonth, in: 1...31)
                Text("Bills and subscriptions are money out; income is money in. The amount is always entered as a positive number.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .navigationTitle(existing == nil ? "Add recurring" : "Edit recurring")
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
        let magnitude = Double(amountText) ?? 0
        let amount = kind == "Income" ? magnitude : -magnitude
        let isSubscription = kind == "Subscription"
        if let existing {
            if let idx = store.recurring.firstIndex(where: { $0.id == existing.id }) {
                store.recurring[idx].name = name
                store.recurring[idx].amount = amount
                store.recurring[idx].dayOfMonth = dayOfMonth
                store.recurring[idx].isSubscription = isSubscription
            }
        } else {
            // Memberwise init order (Models.swift): name, amount,
            // dayOfMonth, isSubscription, previousAmount, looksUnused.
            store.recurring.append(RecurringItem(name: name, amount: amount,
                                                  dayOfMonth: dayOfMonth,
                                                  isSubscription: isSubscription))
        }
        dismiss()
    }
}
