import Foundation

struct Account: Identifiable, Codable {
    var id = UUID()
    var name: String
    var kind: String          // Checking, Savings, Credit Card, Cash, Investment
    var balance: Double       // credit cards are negative
    // Credit-card statement details (manual / statement import — no bank login)
    var statementBalance: Double? = nil
    var minimumDue: Double? = nil
    var dueDay: Int? = nil    // day of month the payment is due
    var creditLimit: Double? = nil
    var note: String? = nil
    /// Annual percentage rate (%) for Credit Card / Loan accounts.
    /// Optional + appended last: Swift's synthesised Decodable uses
    /// decodeIfPresent for optionals, so vault files saved before this
    /// field existed still load with apr == nil.
    var apr: Double? = nil

    var utilisation: Double? {
        guard let limit = creditLimit, limit > 0, let statement = statementBalance else { return nil }
        return statement / limit
    }
}

struct Transaction: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var description: String
    var category: String
    var amount: Double        // negative = spending, positive = income
    var accountID: UUID? = nil
    var isPending: Bool = false
    var isSplit: Bool = false
    var isAutoCategorized: Bool = false
    var needsCategoryConfirm: Bool = false
    var isRecurring: Bool = false
    var tags: [String] = []
}

struct Budget: Identifiable, Codable {
    var id = UUID()
    var category: String
    var limit: Double
    var spent: Double
    var rollover: Bool = false
}

struct WatchlistItem: Identifiable, Codable {
    var id = UUID()
    var kind: String          // Merchant, Category, Tag
    var label: String
    var spent: Double
    var alertAt: Double? = nil
    var detail: String = ""
}

struct SavingsGoal: Identifiable, Codable {
    var id = UUID()
    var name: String
    var icon: String = "target"
    var target: Double
    var saved: Double
    var monthlyContribution: Double
    var targetDate: Date? = nil

    /// Monthly amount needed from now to hit the target date.
    var neededMonthly: Double? {
        guard let targetDate else { return nil }
        let months = max(1, Calendar.current.dateComponents([.month], from: Date(), to: targetDate).month ?? 1)
        return (target - saved) / Double(months)
    }
    var isBehind: Bool {
        guard let needed = neededMonthly else { return false }
        return needed > monthlyContribution + 0.5 && saved < target
    }
}

struct RecurringItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var amount: Double        // negative = bill/subscription, positive = income
    var dayOfMonth: Int
    var isSubscription: Bool = false
    var previousAmount: Double? = nil   // set when the price rose
    var looksUnused: Bool = false

    var priceRose: Bool {
        guard let previous = previousAmount else { return false }
        return abs(amount) > abs(previous)
    }
}

/// One day in the projected cash-flow series.
struct CashPoint: Identifiable {
    var id = UUID()
    var date: Date
    var balance: Double
}

/// Snapshot of everything the app persists, written as JSON on-device
/// (see LedgerFile in SharedStore.swift). NOT encrypted yet — encryption
/// is the vault pass (AES-256-GCM + PBKDF2, see docs/PRIVACY.md) and
/// Settings says so plainly. The file never leaves the device.
/// Field order matters for memberwise inits — do not reorder.
struct PersistedData: Codable {
    var accounts: [Account]
    var transactions: [Transaction]
    var budgets: [Budget]
    var watchlists: [WatchlistItem]
    var goals: [SavingsGoal]
    var recurring: [RecurringItem]
    var manualMonthlyIncome: Double?
    var isDemoMode: Bool
}
