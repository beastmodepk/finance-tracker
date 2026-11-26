import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        if store.isUnlocked {
            VStack(spacing: 0) {
                if store.isDemoMode {
                    Text("DEMO MODE — sample data, nothing real")
                        .font(.caption).bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(Color.ftAmberSoft)
                }
                mainTabs
            }
        } else {
            VaultView()
        }
    }

    private var mainTabs: some View {
        TabView {
            PlaceholderView(title: "Dashboard", systemImage: "chart.pie",
                            note: "Net worth, cash flow and savings rate live here.")
                .tabItem { Label("Dashboard", systemImage: "chart.pie") }
            PlaceholderView(title: "Transactions", systemImage: "list.bullet.rectangle",
                            note: "Searchable ledger and CSV import live here.")
                .tabItem { Label("Transactions", systemImage: "list.bullet.rectangle") }
            PlaceholderView(title: "Spending Plan", systemImage: "wallet.bifold",
                            note: "Budgets by category live here.")
                .tabItem { Label("Plan", systemImage: "wallet.bifold") }
            PlaceholderView(title: "Accounts", systemImage: "building.columns",
                            note: "Accounts and card statement details live here.")
                .tabItem { Label("Accounts", systemImage: "building.columns") }
            PlaceholderView(title: "More", systemImage: "ellipsis.circle",
                            note: "Budgets, goals, recurring, reports, import and settings live here.")
                .tabItem { Label("More", systemImage: "ellipsis.circle") }
        }
        .tint(Color.ftTealDeep)
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
                Text("Private by design: no account, no bank login, no server.")
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
