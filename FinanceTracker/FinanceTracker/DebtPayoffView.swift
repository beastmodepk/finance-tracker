import SwiftUI

/// Debt payoff planner: minimums-only baseline vs Avalanche / Snowball
/// with an extra monthly payment. Pure local maths on the accounts the
/// user entered (balance, APR, minimum due) — deterministic, no network.
struct DebtPayoffView: View {
    @EnvironmentObject var store: Store
    @State private var extraPayment: Double = 100
    @State private var strategy: Strategy = .avalanche

    enum Strategy: String, CaseIterable {
        case avalanche = "Avalanche"
        case snowball = "Snowball"
        var blurb: String {
            switch self {
            case .avalanche: return "Highest APR first — least interest overall."
            case .snowball: return "Smallest balance first — quickest wins."
            }
        }
    }

    private struct Debt {
        var name: String
        var balance: Double   // positive = amount owed
        var apr: Double       // %
        var minimum: Double
    }

    private struct Outcome {
        var months: Int?      // nil = never pays off at this payment level
        var totalInterest: Double
    }

    private var debts: [Debt] {
        store.accounts.filter { $0.balance < 0 }.map { account in
            let owed = abs(account.balance)
            let minimum = account.minimumDue ?? min(owed, max(25, owed * 0.02))
            return Debt(name: account.name, balance: owed,
                        apr: account.apr ?? 0, minimum: minimum)
        }
    }
    private var totalMinimums: Double { debts.reduce(0) { $0 + $1.minimum } }

    private func cents(_ value: Double) -> Double { (value * 100).rounded() / 100 }

    /// One debt paid with only its own minimum every month.
    private func simulateSingle(_ debt: Debt) -> Outcome {
        var balance = debt.balance
        var interest = 0.0
        var months = 0
        while balance > 0.005 && months < 1200 {
            let monthInterest = cents(balance * debt.apr / 100 / 12)
            interest += monthInterest
            balance += monthInterest
            let payment = min(balance, debt.minimum)
            if payment <= monthInterest && balance > debt.minimum { return Outcome(months: nil, totalInterest: interest) }
            balance = cents(balance - payment)
            months += 1
        }
        return Outcome(months: balance <= 0.005 ? months : nil, totalInterest: interest)
    }

    /// All debts together: minimums on everything, then the month's
    /// leftover (freed minimums + extra) cascades onto the strategy target.
    private func simulateCombined(extra: Double, strategy: Strategy) -> Outcome {
        var states = debts
        var interest = 0.0
        var months = 0
        while states.contains(where: { $0.balance > 0.005 }) && months < 1200 {
            for i in states.indices where states[i].balance > 0.005 {
                let monthInterest = cents(states[i].balance * states[i].apr / 100 / 12)
                interest += monthInterest
                states[i].balance += monthInterest
            }
            var budget = totalMinimums + extra
            // Minimums first.
            for i in states.indices where states[i].balance > 0.005 {
                let payment = min(states[i].balance, states[i].minimum, budget)
                states[i].balance = cents(states[i].balance - payment)
                budget -= payment
            }
            // Leftover onto the strategy target(s), in strategy order.
            let order = states.indices
                .filter { states[$0].balance > 0.005 }
                .sorted { a, b in
                    switch strategy {
                    case .avalanche:
                        if states[a].apr != states[b].apr { return states[a].apr > states[b].apr }
                        return states[a].balance < states[b].balance
                    case .snowball:
                        return states[a].balance < states[b].balance
                    }
                }
            for i in order where budget > 0.005 {
                let payment = min(states[i].balance, budget)
                states[i].balance = cents(states[i].balance - payment)
                budget -= payment
            }
            months += 1
        }
        let done = !states.contains(where: { $0.balance > 0.005 })
        return Outcome(months: done ? months : nil, totalInterest: interest)
    }

    private var baseline: Outcome {
        var months: Int? = 0
        var interest = 0.0
        for debt in debts {
            let outcome = simulateSingle(debt)
            interest += outcome.totalInterest
            if let m = outcome.months, let current = months {
                months = max(current, m)
            } else {
                months = nil
            }
        }
        return Outcome(months: months, totalInterest: interest)
    }

    private func payoffDate(_ outcome: Outcome) -> String {
        guard let months = outcome.months else { return "Not at this payment" }
        let date = Calendar.current.date(byAdding: .month, value: months, to: Date()) ?? Date()
        let f = DateFormatter()
        f.dateFormat = "MMM yyyy"
        return f.string(from: date)
    }

    var body: some View {
        Group {
            if debts.isEmpty {
                ContentUnavailableView {
                    Label("No debts — nice.", systemImage: "checkmark.seal")
                } description: {
                    Text("When you add a credit card or loan with a balance, APR and minimum due, this planner shows your debt-free date and how much interest you can save.")
                }
            } else {
                planner
            }
        }
        .navigationTitle("Debt payoff")
    }

    private var planner: some View {
        let base = baseline
        let chosen = simulateCombined(extra: extraPayment, strategy: strategy)
        let other: Strategy = strategy == .avalanche ? .snowball : .avalanche
        let otherOutcome = simulateCombined(extra: extraPayment, strategy: other)
        return List {
            Section("Your debts") {
                ForEach(debts, id: \.name) { debt in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(debt.name)
                            Text(String(format: "APR %.2f%% · min %@", debt.apr, money(debt.minimum)))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(money(debt.balance)).bold()
                    }
                    .font(.subheadline)
                }
            }
            Section {
                Slider(value: $extraPayment, in: 0...500, step: 10)
                HStack {
                    Text("Extra payment")
                    Spacer()
                    Text("\(money(extraPayment))/mo").bold()
                }
                .font(.subheadline)
                Text("Total going to debt: \(money(totalMinimums + extraPayment))/mo (minimums \(money(totalMinimums)) + extra).")
                    .font(.caption).foregroundStyle(.secondary)
            } header: {
                Text("Extra monthly payment")
            }
            Section {
                Picker("Strategy", selection: $strategy) {
                    ForEach(Strategy.allCases, id: \.self) { Text($0.rawValue) }
                }
                .pickerStyle(.segmented)
                Text(strategy.blurb).font(.caption).foregroundStyle(.secondary)
            } header: {
                Text("Strategy")
            }
            Section("Your plan — \(strategy.rawValue)") {
                resultRow("Debt-free date", payoffDate(chosen))
                if let months = chosen.months {
                    resultRow("Months to debt-free", "\(months)")
                }
                resultRow("Total interest", money(chosen.totalInterest))
                if base.totalInterest > chosen.totalInterest {
                    HStack {
                        Text("Interest saved vs minimums-only")
                        Spacer()
                        Text(money(base.totalInterest - chosen.totalInterest))
                            .bold().foregroundStyle(Color.ftTealText)
                    }
                    .font(.subheadline)
                }
                Text("Minimums-only: debt-free \(payoffDate(base)), \(money(base.totalInterest)) interest.")
                    .font(.caption).foregroundStyle(.secondary)
                Text("\(other.rawValue) with the same payment: debt-free \(payoffDate(otherOutcome)), \(money(otherOutcome.totalInterest)) interest.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section {
                Text("Estimates from the balances, APRs and minimums you entered — no bank login, and nothing here changes your real accounts.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private func resultRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).bold()
        }
        .font(.subheadline)
    }
}
