import Foundation

/// On-disk ledger access shared by the app, the Siri App Intent and the
/// widget snapshot writer.
///
/// The ledger JSON lives in the App Group container
/// (group.com.parthey.financetracker) so processes outside the main app
/// (the intent, later the widget) can reach the same file. If the App
/// Group container is unavailable (e.g. an unsigned build), it falls
/// back to the app's own Application Support folder — the location used
/// before App Groups existed, which is also checked on load so existing
/// users' data is picked up and migrated on the next save.
enum LedgerFile {
    static let appGroupID = "group.com.parthey.financetracker"
    static let fileName = "vault-data.json"

    static var dataFileURL: URL? {
        if let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            return container.appendingPathComponent(fileName)
        }
        return legacyFileURL
    }

    static var legacyFileURL: URL? {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("FinanceTracker", isDirectory: true)
            .appendingPathComponent(fileName)
    }

    static func load() -> PersistedData? {
        for url in [dataFileURL, legacyFileURL] {
            guard let url, let data = try? Data(contentsOf: url),
                  let decoded = try? JSONDecoder().decode(PersistedData.self, from: data) else {
                continue
            }
            return decoded
        }
        return nil
    }

    static func save(_ snapshot: PersistedData) {
        guard let url = dataFileURL,
              let data = try? JSONEncoder().encode(snapshot) else { return }
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                 withIntermediateDirectories: true)
        try? data.write(to: url, options: [.atomic])
    }

    /// Read-modify-write used by the Siri intent, which may run while
    /// the main app isn't in memory. The app picks the change up on its
    /// next activation (Store.reloadFromDisk).
    static func appendExpense(amount: Double, description: String, category: String) {
        var data = load() ?? PersistedData(accounts: [], transactions: [], budgets: [],
                                           watchlists: [], goals: [], recurring: [],
                                           manualMonthlyIncome: nil, isDemoMode: false)
        // Memberwise init order (Models.swift): date, description,
        // category, amount, accountID, isPending, isSplit,
        // isAutoCategorized, needsCategoryConfirm, isRecurring, tags.
        let tx = Transaction(date: Date(), description: description,
                             category: category, amount: -abs(amount))
        data.transactions.insert(tx, at: 0)
        save(data)
        WidgetSnapshot.make(from: data).writeToSharedDefaults()
    }
}

/// Small Codable snapshot the app publishes to the App Group
/// UserDefaults whenever the ledger saves; the home-screen widget reads
/// it. The widget target carries its own copy of this struct — keep the
/// two in sync.
struct WidgetSnapshot: Codable {
    var safeToSpend: Double
    var netWorth: Double
    var nextBillName: String
    var nextBillAmount: Double
    var nextBillDay: Int
    var updatedAt: Date

    static let placeholder = WidgetSnapshot(safeToSpend: 1710.06, netWorth: 38240,
                                            nextBillName: "Rent", nextBillAmount: 1650,
                                            nextBillDay: 1, updatedAt: Date())

    /// Mirrors Store's safe-to-spend / net-worth / upcoming-bill maths
    /// so writers outside the app process (the Siri intent) can publish
    /// a correct snapshot too.
    static func make(from data: PersistedData) -> WidgetSnapshot {
        let income = data.manualMonthlyIncome
            ?? data.recurring.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
        let bills = abs(data.recurring.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount })
        let goalContributions = data.goals.reduce(0) { $0 + $1.monthlyContribution }
        let spent = abs(data.transactions
            .filter { $0.date.isThisMonth && $0.amount < 0 && $0.category != "Bills" && $0.category != "Transfer" }
            .reduce(0) { $0 + $1.amount })
        let netWorth = data.accounts.reduce(0) { $0 + $1.balance }
        let today = Calendar.current.component(.day, from: Date())
        let nextBill = data.recurring.filter { $0.amount < 0 }
            .sorted { ($0.dayOfMonth - today + 31) % 31 < ($1.dayOfMonth - today + 31) % 31 }
            .first
        return WidgetSnapshot(safeToSpend: income - bills - goalContributions - spent,
                              netWorth: netWorth,
                              nextBillName: nextBill?.name ?? "—",
                              nextBillAmount: abs(nextBill?.amount ?? 0),
                              nextBillDay: nextBill?.dayOfMonth ?? 0,
                              updatedAt: Date())
    }

    func writeToSharedDefaults() {
        guard let defaults = UserDefaults(suiteName: LedgerFile.appGroupID),
              let data = try? JSONEncoder().encode(self) else { return }
        defaults.set(data, forKey: "widgetSnapshot")
    }
}
