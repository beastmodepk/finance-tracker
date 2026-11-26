import AppIntents

/// "Log expense in Finance Tracker" — a Siri / Shortcuts entry point
/// that appends one expense to the on-device ledger.
///
/// The intent can run while the main app is not in memory, so it writes
/// through LedgerFile (read-modify-write of the shared App Group JSON)
/// rather than touching the in-memory Store. The app reconciles on its
/// next activation via Store.reloadFromDisk, and the intent refreshes
/// the widget snapshot itself.
struct LogExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Expense"
    static var description = IntentDescription(
        "Adds an expense to your Finance Tracker ledger. Everything stays on this phone — no account, no server.")

    @Parameter(title: "Amount", description: "How much you spent, in dollars.")
    var amount: Double

    @Parameter(title: "What for", description: "What the expense was for, e.g. Coffee.")
    var itemName: String

    @Parameter(title: "Category",
               description: "Category for the expense, e.g. Dining or Groceries.",
               default: "Other")
    var category: String

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$amount) for \(\.$itemName)")
    }

    func perform() async throws -> some IntentResult {
        LedgerFile.appendExpense(amount: amount, description: itemName, category: category)
        return .result()
    }
}

struct FinanceTrackerShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogExpenseIntent(),
            phrases: [
                "Log expense in \(.applicationName)",
                "Add an expense to \(.applicationName)",
            ],
            shortTitle: "Log Expense",
            systemImageName: "plus.circle"
        )
    }
}
