import Foundation

/// App state for the UI build.
///
/// IMPORTANT (honest status): the vault here is a UI gate only — unlocked
/// state is in-memory and demo data lives in memory. Real encrypted
/// persistence (AES-256-GCM + PBKDF2, see docs/PRIVACY.md) lands next and
/// Settings says so plainly. Nothing here is sent anywhere.
@MainActor
final class Store: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var transactions: [Transaction] = []
    @Published var budgets: [Budget] = []
    @Published var watchlists: [WatchlistItem] = []
    @Published var goals: [SavingsGoal] = []
    @Published var recurring: [RecurringItem] = []

    @Published var isUnlocked = false
    @Published var isDemoMode = false

    // MARK: - Vault (UI gate only in this build)

    func unlock(passphrase: String) -> Bool {
        // Demo passphrase opens the demo vault. Any passphrase set at
        // "create" time is accepted in this UI build (in-memory only).
        if passphrase == "Demo1234!" {
            loadDemoData()
            isDemoMode = true
            isUnlocked = true
            return true
        }
        if passphrase.count >= 4 {
            isDemoMode = false
            isUnlocked = true
            return true
        }
        return false
    }

    func openDemoVault() {
        loadDemoData()
        isDemoMode = true
        isUnlocked = true
    }

    func lock() {
        isUnlocked = false
    }

    func wipeVault() {
        accounts = []
        transactions = []
        budgets = []
        watchlists = []
        goals = []
        recurring = []
        isDemoMode = false
        isUnlocked = false
    }

    // MARK: - Computed

    var netWorth: Double { accounts.reduce(0) { $0 + $1.balance } }
    var totalAssets: Double { accounts.filter { $0.balance > 0 }.reduce(0) { $0 + $1.balance } }
    var totalDebts: Double { abs(accounts.filter { $0.balance < 0 }.reduce(0) { $0 + $1.balance }) }

    var expectedMonthlyIncome: Double {
        recurring.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
    }
    var monthlyBillsTotal: Double {
        abs(recurring.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount })
    }
    var monthlyGoalContributions: Double {
        goals.reduce(0) { $0 + $1.monthlyContribution }
    }
    /// Discretionary spending this month (excludes Bills, Transfers, Income).
    var spentThisMonth: Double {
        abs(transactions
            .filter { $0.date.isThisMonth && $0.amount < 0 && $0.category != "Bills" && $0.category != "Transfer" }
            .reduce(0) { $0 + $1.amount })
    }
    var incomeThisMonth: Double {
        transactions.filter { $0.date.isThisMonth && $0.amount > 0 }.reduce(0) { $0 + $1.amount }
    }
    var allSpendingThisMonth: Double {
        abs(transactions.filter { $0.date.isThisMonth && $0.amount < 0 && $0.category != "Transfer" }
            .reduce(0) { $0 + $1.amount })
    }
    var safeToSpend: Double {
        expectedMonthlyIncome - monthlyBillsTotal - monthlyGoalContributions - spentThisMonth
    }
    var savingsRate: Double {
        guard incomeThisMonth > 0 else { return 0 }
        return max(0, (incomeThisMonth - allSpendingThisMonth) / incomeThisMonth)
    }

    var spendingByCategory: [(category: String, total: Double)] {
        var totals: [String: Double] = [:]
        for tx in transactions where tx.amount < 0 && tx.category != "Transfer" {
            totals[tx.category, default: 0] += abs(tx.amount)
        }
        return totals.map { (category: $0.key, total: $0.value) }.sorted { $0.total > $1.total }
    }

    var upcomingRecurring: [RecurringItem] {
        let today = Calendar.current.component(.day, from: Date())
        return recurring.filter { $0.amount < 0 }
            .sorted { ($0.dayOfMonth - today + 31) % 31 < ($1.dayOfMonth - today + 31) % 31 }
    }

    /// Deterministic 90-day projection of the checking balance from
    /// recurring income/bills on their day of month.
    var projectedCashFlow: [CashPoint] {
        let cal = Calendar.current
        var balance = accounts.first { $0.kind == "Checking" }?.balance ?? 0
        var points: [CashPoint] = []
        var date = Date()
        for _ in 0...90 {
            let day = cal.component(.day, from: date)
            for item in recurring where item.dayOfMonth == day {
                balance += item.amount
            }
            points.append(CashPoint(date: date, balance: balance))
            date = cal.date(byAdding: .day, value: 1, to: date) ?? date
        }
        return points
    }

    // MARK: - Demo data (labelled demo, in-memory only)

    func loadDemoData() {
        let checking = Account(name: "Checking", kind: "Checking", balance: 3214, note: "Updated today · manual / imported")
        let savings = Account(name: "Savings", kind: "Savings", balance: 12480, note: "APY 4.1% (manual note)")
        let travelCard = Account(name: "Travel Card", kind: "Credit Card", balance: -1850,
                                 statementBalance: 1850, minimumDue: 55, dueDay: 28, creditLimit: 8000)
        let everydayCard = Account(name: "Everyday Card", kind: "Credit Card", balance: -1000,
                                   statementBalance: 1000, minimumDue: 31, dueDay: 12, creditLimit: 5000)
        let investments = Account(name: "Investments", kind: "Investment", balance: 25276, note: "Manual balance · live holdings later")
        let cash = Account(name: "Cash", kind: "Cash", balance: 120)
        accounts = [checking, savings, travelCard, everydayCard, investments, cash]

        transactions = [
            Transaction(date: dayThisMonth(1), description: "Payroll — Employer", category: "Income", amount: 2425, accountID: checking.id),
            Transaction(date: dayThisMonth(15), description: "Payroll — Employer", category: "Income", amount: 2425, accountID: checking.id),
            Transaction(date: dayThisMonth(1), description: "Rent", category: "Bills", amount: -1650, accountID: checking.id, isRecurring: true),
            Transaction(date: dayThisMonth(3), description: "Electric utility", category: "Bills", amount: -94.12, accountID: checking.id, isRecurring: true),
            Transaction(date: dayThisMonth(4), description: "Market Basket", category: "Groceries", amount: -86.20, accountID: travelCard.id, isAutoCategorized: true, isSplit: true),
            Transaction(date: dayThisMonth(6), description: "Phone bill", category: "Bills", amount: -55, accountID: checking.id, isRecurring: true),
            Transaction(date: dayThisMonth(7), description: "Coffee Shop", category: "Dining", amount: -6.40, accountID: everydayCard.id, isAutoCategorized: true, needsCategoryConfirm: true),
            Transaction(date: dayThisMonth(8), description: "Groceries — Trader Joe's", category: "Groceries", amount: -132.45, accountID: checking.id),
            Transaction(date: dayThisMonth(9), description: "Gas station", category: "Transport", amount: -68, accountID: everydayCard.id),
            Transaction(date: dayThisMonth(10), description: "Streaming A", category: "Bills", amount: -15.49, accountID: everydayCard.id, isRecurring: true),
            Transaction(date: dayThisMonth(11), description: "Music B", category: "Bills", amount: -11.99, accountID: everydayCard.id, isRecurring: true),
            Transaction(date: dayThisMonth(12), description: "Card payment", category: "Transfer", amount: -200, accountID: checking.id, isPending: true),
            Transaction(date: dayThisMonth(13), description: "Dinner — Border Cafe", category: "Dining", amount: -64, accountID: travelCard.id),
            Transaction(date: dayThisMonth(14), description: "Cloud storage", category: "Bills", amount: -12.99, accountID: everydayCard.id, isRecurring: true),
            Transaction(date: dayThisMonth(16), description: "Gym app", category: "Bills", amount: -29, accountID: everydayCard.id, isRecurring: true),
            Transaction(date: dayThisMonth(17), description: "Gift for family", category: "Gifts", amount: -75, accountID: checking.id),
            Transaction(date: dayThisMonth(18), description: "Online shopping", category: "Shopping", amount: -119.30, accountID: travelCard.id, isAutoCategorized: true, needsCategoryConfirm: true),
            Transaction(date: dayThisMonth(19), description: "Farmers market", category: "Groceries", amount: -94, accountID: cash.id, isPending: true),
        ].sorted { $0.date > $1.date }

        budgets = [
            Budget(category: "Groceries", limit: 550, spent: 412, rollover: true),
            Budget(category: "Dining", limit: 220, spent: 268, rollover: false),
            Budget(category: "Transport", limit: 150, spent: 132, rollover: false),
            Budget(category: "Shopping", limit: 200, spent: 119, rollover: true),
        ]
        watchlists = [
            WatchlistItem(kind: "Merchant", label: "Delivery apps", spent: 96, alertAt: 120, detail: "14 orders this month"),
            WatchlistItem(kind: "Category", label: "Coffee", spent: 38, alertAt: 85, detail: ""),
            WatchlistItem(kind: "Tag", label: "#work lunches", spent: 121, alertAt: nil, detail: "View only · no alert"),
        ]
        goals = [
            SavingsGoal(name: "Holiday trip", icon: "airplane", target: 2000, saved: 1150, monthlyContribution: 150, targetDate: monthsFromNow(6)),
            SavingsGoal(name: "Emergency fund", icon: "lifepreserver", target: 10000, saved: 8400, monthlyContribution: 150, targetDate: monthsFromNow(11)),
            SavingsGoal(name: "Car deposit", icon: "car", target: 3000, saved: 600, monthlyContribution: 50, targetDate: monthsFromNow(7)),
            SavingsGoal(name: "Holiday gifts", icon: "gift", target: 400, saved: 210, monthlyContribution: 0, targetDate: monthsFromNow(1)),
        ]
        recurring = [
            RecurringItem(name: "Payroll — Employer", amount: 2425, dayOfMonth: 1),
            RecurringItem(name: "Payroll — Employer", amount: 2425, dayOfMonth: 15),
            RecurringItem(name: "Rent", amount: -1650, dayOfMonth: 1),
            RecurringItem(name: "Electric", amount: -94.12, dayOfMonth: 3),
            RecurringItem(name: "Phone", amount: -55, dayOfMonth: 6),
            RecurringItem(name: "Internet", amount: -79, dayOfMonth: 9),
            RecurringItem(name: "Insurance", amount: -142, dayOfMonth: 20),
            RecurringItem(name: "Travel Card minimum", amount: -55, dayOfMonth: 28),
            RecurringItem(name: "Streaming A", amount: -15.49, dayOfMonth: 10, isSubscription: true),
            RecurringItem(name: "Music B", amount: -11.99, dayOfMonth: 11, isSubscription: true),
            RecurringItem(name: "Cloud storage", amount: -12.99, dayOfMonth: 14, isSubscription: true, previousAmount: -9.99),
            RecurringItem(name: "Gym app", amount: -29, dayOfMonth: 16, isSubscription: true, looksUnused: true),
        ]
    }
}
