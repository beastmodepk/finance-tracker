import SwiftUI

struct GoalsView: View {
    @EnvironmentObject var store: Store
    @State private var showAdd = false
    @State private var editing: SavingsGoal? = nil

    var body: some View {
        Group {
            if store.goals.isEmpty {
                ContentUnavailableView {
                    Label("No goals yet", systemImage: "target")
                } description: {
                    Text("Add a savings goal — a trip, a deposit, a safety net — and the Spending Plan reserves money for it before “safe to spend”.")
                } actions: {
                    Button("Add your first goal") { showAdd = true }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.ftTeal)
                }
            } else {
                goalList
            }
        }
        .navigationTitle("Savings goals")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showAdd = true } label: { Label("Add goal", systemImage: "plus") }
            }
        }
        .sheet(isPresented: $showAdd) { GoalFormView(existing: nil) }
        .sheet(item: $editing) { goal in GoalFormView(existing: goal) }
    }

    private var goalList: some View {
        List {
            Section {
                Text("Goals live inside the Spending Plan — \(money(store.monthlyGoalContributions))/mo is reserved before “safe to spend”. Tap a goal to edit it; swipe left to delete.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            ForEach(store.goals) { goal in
                VStack(alignment: .leading, spacing: 5) {
                    Button { editing = goal } label: {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Image(systemName: goal.icon).foregroundStyle(Color.ftTealText)
                                Text(goal.name).bold()
                                Spacer()
                                Text("\(money(goal.saved)) / \(money(goal.target))")
                                    .foregroundStyle(goal.isBehind ? .red : .primary)
                            }
                            ProgressView(value: min(goal.saved, goal.target), total: max(goal.target, 1))
                                .tint(goal.isBehind ? .red : Color.ftTeal)
                            if goal.isBehind, let needed = goal.neededMonthly {
                                Text("Behind — at \(money(goal.monthlyContribution))/mo you'll miss the date. Needs about \(money(needed))/mo.")
                                    .font(.caption).foregroundStyle(.red)
                            } else if goal.monthlyContribution > 0 {
                                Text("\(money(goal.monthlyContribution))/mo · On track")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    HStack(spacing: 10) {
                        Button("+ $25") { store.quickAdd(toGoal: goal.id, amount: 25) }
                            .buttonStyle(.bordered).tint(Color.ftTeal)
                        Button("+ $100") { store.quickAdd(toGoal: goal.id, amount: 100) }
                            .buttonStyle(.bordered).tint(Color.ftTeal)
                    }
                }
                .padding(.vertical, 2)
            }
            .onDelete { offsets in
                store.goals.remove(atOffsets: offsets)
            }
        }
    }
}

/// Add / edit form for one savings goal.
struct GoalFormView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    let existing: SavingsGoal?
    @State private var name: String
    @State private var icon: String
    @State private var targetText: String
    @State private var savedText: String
    @State private var monthlyText: String
    @State private var hasTargetDate: Bool
    @State private var targetDate: Date

    static let icons = ["target", "airplane", "lifepreserver", "car", "gift",
                        "house", "graduationcap", "heart.fill", "bicycle",
                        "laptopcomputer", "beach.umbrella", "shield"]

    init(existing: SavingsGoal?) {
        self.existing = existing
        _name = State(initialValue: existing?.name ?? "")
        _icon = State(initialValue: existing?.icon ?? "target")
        _targetText = State(initialValue: existing.map { String(format: "%.2f", $0.target) } ?? "")
        _savedText = State(initialValue: existing.map { String(format: "%.2f", $0.saved) } ?? "0")
        _monthlyText = State(initialValue: existing.map { String(format: "%.2f", $0.monthlyContribution) } ?? "")
        _hasTargetDate = State(initialValue: existing?.targetDate != nil)
        _targetDate = State(initialValue: existing?.targetDate ?? monthsFromNow(6))
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Goal name", text: $name)
                Picker("Icon", selection: $icon) {
                    ForEach(Self.icons, id: \.self) { symbol in
                        Label(symbol, systemImage: symbol).tag(symbol)
                    }
                }
                TextField("Target amount", text: $targetText)
                    .keyboardType(.decimalPad)
                TextField("Already saved", text: $savedText)
                    .keyboardType(.decimalPad)
                TextField("Monthly contribution", text: $monthlyText)
                    .keyboardType(.decimalPad)
                Toggle("Has a target date", isOn: $hasTargetDate)
                if hasTargetDate {
                    DatePicker("Target date", selection: $targetDate, displayedComponents: .date)
                }
            }
            .navigationTitle(existing == nil ? "Add goal" : "Edit goal")
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
        let target = Double(targetText) ?? 0
        let saved = Double(savedText) ?? 0
        let monthly = Double(monthlyText) ?? 0
        let date: Date? = hasTargetDate ? targetDate : nil
        if let existing {
            if let idx = store.goals.firstIndex(where: { $0.id == existing.id }) {
                store.goals[idx].name = name
                store.goals[idx].icon = icon
                store.goals[idx].target = target
                store.goals[idx].saved = saved
                store.goals[idx].monthlyContribution = monthly
                store.goals[idx].targetDate = date
            }
        } else {
            // Memberwise init order (Models.swift): name, icon, target,
            // saved, monthlyContribution, targetDate.
            store.goals.append(SavingsGoal(name: name, icon: icon, target: target,
                                           saved: saved, monthlyContribution: monthly,
                                           targetDate: date))
        }
        dismiss()
    }
}
