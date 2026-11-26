import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink { BudgetsView() } label: { Label("Budgets & Watchlists", systemImage: "chart.bar") }
                NavigationLink { GoalsView() } label: { Label("Goals", systemImage: "target") }
                NavigationLink { RecurringView() } label: { Label("Recurring & Subscriptions", systemImage: "repeat") }
                NavigationLink {
                    PlaceholderView(title: "Reports", systemImage: "chart.pie", note: "Reports arrive in the next commit of this build.")
                } label: { Label("Reports", systemImage: "chart.pie") }
                NavigationLink {
                    PlaceholderView(title: "Import", systemImage: "square.and.arrow.down", note: "The migration wizard arrives in the next commit of this build.")
                } label: { Label("Import / Migration", systemImage: "square.and.arrow.down") }
                NavigationLink {
                    PlaceholderView(title: "Settings", systemImage: "gearshape", note: "Settings arrive in the next commit of this build.")
                } label: { Label("Settings & Privacy", systemImage: "gearshape") }
            }
            .navigationTitle("More")
        }
    }
}
