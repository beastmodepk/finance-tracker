import Foundation

/// Skeleton store for the Apple-ready build.
/// Design and the encrypted vault (AES-256-GCM + PBKDF2, see docs/PRIVACY.md)
/// land in the design phase — this type is the single home for app state
/// so those changes have one place to go.
@MainActor
final class Store: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var transactions: [Transaction] = []
    @Published var budgets: [Budget] = []
    @Published var goals: [SavingsGoal] = []

    var netWorth: Double { accounts.reduce(0) { $0 + $1.balance } }
}
