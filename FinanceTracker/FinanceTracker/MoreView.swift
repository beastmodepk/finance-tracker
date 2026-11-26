import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink { BudgetsView() } label: { Label("Budgets & Watchlists", systemImage: "chart.bar") }
                NavigationLink { GoalsView() } label: { Label("Goals", systemImage: "target") }
                NavigationLink { RecurringView() } label: { Label("Recurring & Subscriptions", systemImage: "repeat") }
                NavigationLink { DebtPayoffView() } label: { Label("Debt Payoff Planner", systemImage: "chart.line.downtrend.xyaxis") }
                NavigationLink { ReportsView() } label: { Label("Reports", systemImage: "chart.pie") }
                NavigationLink { ImportView() } label: { Label("Import / Migration", systemImage: "square.and.arrow.down") }
                NavigationLink { SettingsView() } label: { Label("Settings & Privacy", systemImage: "gearshape") }
            }
            .navigationTitle("More")
        }
    }
}
