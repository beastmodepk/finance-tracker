import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            content
        }
        // The Siri intent can write to the shared ledger while the app
        // is backgrounded; reconcile whenever we come back to the front.
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { store.reloadFromDisk() }
        }
    }

    private var content: some View {
        if store.isUnlocked {
            VStack(spacing: 0) {
                if store.isDemoMode {
                    Text("DEMO MODE — sample data, nothing real")
                        .font(.caption).bold()
                        .foregroundStyle(Color.ftAmberText)
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
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.pie") }
            TransactionsView()
                .tabItem { Label("Transactions", systemImage: "list.bullet.rectangle") }
            SpendingPlanView()
                .tabItem { Label("Plan", systemImage: "wallet.bifold") }
            AccountsView()
                .tabItem { Label("Accounts", systemImage: "building.columns") }
            MoreView()
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
