import SwiftUI
import UIKit

/// Palette from the approved wireframes (emerald / cream / amber).
///
/// DARK-MODE CONTRACT: every surface/tint token below is ADAPTIVE — it
/// resolves through a `UIColor` dynamic provider, so a token that is a
/// pale tint in Light Mode becomes a deep tint in Dark Mode. Text tokens
/// (`ftTealText`, `ftAmberText`) are chosen to keep ≥4.5:1 contrast
/// against their matching tint/surface in BOTH appearances. Views must
/// never pair `.white`/`.primary` text with a hardcoded light colour —
/// pair text with these tokens instead:
///   - card surfaces ......... `ftCream` (alias `ftSurface`)
///   - teal pill background .. `ftTealSoft`  + text `ftTealText`
///   - amber pill background . `ftAmberSoft` + text `ftAmberText`
///   - filled emerald ........ `ftTealDeep`  + text `.white` (only here)
private func ftDynamic(light: (Double, Double, Double), dark: (Double, Double, Double)) -> Color {
    Color(UIColor { traits in
        let rgb = traits.userInterfaceStyle == .dark ? dark : light
        return UIColor(red: CGFloat(rgb.0), green: CGFloat(rgb.1), blue: CGFloat(rgb.2), alpha: 1)
    })
}

extension Color {
    /// Brand emerald for filled accents / chart lines. Brightens in Dark Mode.
    static let ftTeal = ftDynamic(light: (0.055, 0.478, 0.404), dark: (0.216, 0.851, 0.741))   // #0E7A67 / #37D9BD
    /// Deep emerald — use ONLY as a filled background with white text on top.
    static let ftTealDeep = Color(red: 0.039, green: 0.369, blue: 0.314)                        // #0A5E50
    /// Card surface: cream in Light Mode, near-black grey in Dark Mode.
    static let ftCream = ftDynamic(light: (0.957, 0.961, 0.945), dark: (0.110, 0.110, 0.118))    // #F4F5F1 / #1C1C1E
    /// Semantic alias for `ftCream` — the adaptive card surface token.
    static let ftSurface = ftCream
    static let ftAmber = Color(red: 0.851, green: 0.467, blue: 0.024)                            // #D97706 (icons/accents, not body text)
    /// Pale teal tint for pills — deep teal tint in Dark Mode.
    static let ftTealSoft = ftDynamic(light: (0.878, 0.941, 0.922), dark: (0.051, 0.231, 0.200))
    /// Pale amber tint for pills/banners — deep amber tint in Dark Mode.
    static let ftAmberSoft = ftDynamic(light: (0.996, 0.953, 0.780), dark: (0.302, 0.212, 0.043))
    /// Pale red tint — deep red tint in Dark Mode.
    static let ftRedSoft = ftDynamic(light: (0.992, 0.925, 0.918), dark: (0.322, 0.110, 0.098))
    /// Emerald text that stays readable on `ftTealSoft`/`ftCream` in both modes.
    static let ftTealText = ftDynamic(light: (0.039, 0.369, 0.314), dark: (0.451, 0.882, 0.765)) // #0A5E50 / #73E1C3
    /// Amber-brown text that stays readable on `ftAmberSoft` in both modes.
    static let ftAmberText = ftDynamic(light: (0.573, 0.251, 0.055), dark: (0.984, 0.749, 0.141)) // #92400E / #FBBF24
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
