import SwiftUI

/// Palette from the approved wireframes (emerald / cream / amber).
extension Color {
    static let ftTeal = Color(red: 0.055, green: 0.478, blue: 0.404)        // #0E7A67
    static let ftTealDeep = Color(red: 0.039, green: 0.369, blue: 0.314)    // #0A5E50
    static let ftCream = Color(red: 0.957, green: 0.961, blue: 0.945)        // #F4F5F1
    static let ftAmber = Color(red: 0.851, green: 0.467, blue: 0.024)       // #D97706
    static let ftTealSoft = Color(red: 0.878, green: 0.941, blue: 0.922)
    static let ftAmberSoft = Color(red: 0.996, green: 0.953, blue: 0.780)
    static let ftRedSoft = Color(red: 0.992, green: 0.925, blue: 0.918)
}

func money(_ value: Double, signed: Bool = false) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"
    formatter.maximumFractionDigits = (value.truncatingRemainder(dividingBy: 1) == 0 && !signed) ? 0 : 2
    formatter.minimumFractionDigits = 0
    let base = formatter.string(from: NSNumber(value: abs(value))) ?? "$0"
    if value < 0 { return "−" + base }
    if signed && value > 0 { return "+" + base }
    return base
}

extension Date {
    var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    var shortDay: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: self)
    }
}

/// Build a date in the current month (clamped to today for past-looking demo rows).
func dayThisMonth(_ day: Int, hour: Int = 12) -> Date {
    let cal = Calendar.current
    var comps = cal.dateComponents([.year, .month], from: Date())
    comps.day = min(day, 28)
    comps.hour = hour
    return cal.date(from: comps) ?? Date()
}

func monthsFromNow(_ months: Int) -> Date {
    Calendar.current.date(byAdding: .month, value: months, to: Date()) ?? Date()
}
