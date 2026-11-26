import Foundation

struct Account: Identifiable, Codable {
    var id = UUID()
    var name: String
    var kind: String          // Checking, Savings, Credit Card, Cash, Investment
    var balance: Double
}

struct Transaction: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var description: String
    var category: String
    var amount: Double        // negative = spending, positive = income
    var accountID: UUID?
}

struct Budget: Identifiable, Codable {
    var id = UUID()
    var category: String
    var limit: Double
    var spent: Double
}

struct SavingsGoal: Identifiable, Codable {
    var id = UUID()
    var name: String
    var target: Double
    var saved: Double
}
