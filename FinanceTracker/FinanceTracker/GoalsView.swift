import SwiftUI

struct GoalsView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        List {
            Section {
                Text("Goals live inside the Spending Plan — \(money(store.monthlyGoalContributions))/mo is reserved before “safe to spend”.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            ForEach($store.goals) { $goal in
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: goal.icon).foregroundStyle(Color.ftTealDeep)
                        Text(goal.name).bold()
                        Spacer()
                        Text("\(money(goal.saved)) / \(money(goal.target))")
                            .foregroundStyle(goal.isBehind ? .red : .primary)
                    }
                    ProgressView(value: min(goal.saved, goal.target), total: goal.target)
                        .tint(goal.isBehind ? .red : Color.ftTeal)
                    if goal.isBehind, let needed = goal.neededMonthly {
                        Text("Behind — at \(money(goal.monthlyContribution))/mo you'll miss the date. Needs about \(money(needed))/mo.")
                            .font(.caption).foregroundStyle(.red)
                    } else if goal.monthlyContribution > 0 {
                        Text("\(money(goal.monthlyContribution))/mo · On track")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    HStack(spacing: 10) {
                        Button("+ $25") { goal.saved = min(goal.target, goal.saved + 25) }
                            .buttonStyle(.bordered).tint(Color.ftTeal)
                        Button("+ $100") { goal.saved = min(goal.target, goal.saved + 100) }
                            .buttonStyle(.bordered).tint(Color.ftTeal)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .navigationTitle("Savings goals")
    }
}
