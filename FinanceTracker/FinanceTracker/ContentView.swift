import SwiftUI

/// Placeholder shell — final design is worked on with the owner next.
/// Tabs mirror the settled core screens in docs/DESIGN.md so design
/// work can drop into each one independently.
struct ContentView: View {
    var body: some View {
        TabView {
            PlaceholderView(title: "Dashboard",
                            systemImage: "chart.pie",
                            note: "Net worth, cash flow and savings rate live here.")
                .tabItem { Label("Dashboard", systemImage: "chart.pie") }

            PlaceholderView(title: "Transactions",
                            systemImage: "list.bullet.rectangle",
                            note: "Searchable ledger and CSV import live here.")
                .tabItem { Label("Transactions", systemImage: "list.bullet.rectangle") }

            PlaceholderView(title: "Spending Plan",
                            systemImage: "wallet.bifold",
                            note: "Budgets by category live here.")
                .tabItem { Label("Plan", systemImage: "wallet.bifold") }

            PlaceholderView(title: "Goals",
                            systemImage: "target",
                            note: "Savings goals live here.")
                .tabItem { Label("Goals", systemImage: "target") }
        }
    }
}

struct PlaceholderView: View {
    let title: String
    let systemImage: String
    let note: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 44))
                    .foregroundStyle(.secondary)
                Text(note)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Text("Design coming next — private by design: no account, no bank login, no server.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal)
            }
            .padding()
            .navigationTitle(title)
        }
    }
}

#Preview {
    ContentView().environmentObject(Store())
}
