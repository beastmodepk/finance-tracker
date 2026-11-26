import SwiftUI
import WidgetKit

// MARK: - Snapshot (widget-local copy)
//
// The app publishes this JSON to the App Group UserDefaults under
// "widgetSnapshot" whenever the ledger saves (see WidgetSnapshot in the
// app's SharedStore.swift — keep the two structs in sync).

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
}

private func widgetMoney(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"
    formatter.maximumFractionDigits = value.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
    formatter.minimumFractionDigits = 0
    let base = formatter.string(from: NSNumber(value: abs(value))) ?? "$0"
    return value < 0 ? "−" + base : base
}

// MARK: - Timeline

struct FinanceEntry: TimelineEntry {
    var date: Date
    var snapshot: WidgetSnapshot
}

struct FinanceProvider: TimelineProvider {
    private static let appGroupID = "group.com.parthey.financetracker"

    static func load() -> WidgetSnapshot {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: "widgetSnapshot"),
              let decoded = try? JSONDecoder().decode(WidgetSnapshot.self, from: data) else {
            return .placeholder
        }
        return decoded
    }

    func placeholder(in context: Context) -> FinanceEntry {
        FinanceEntry(date: Date(), snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (FinanceEntry) -> Void) {
        completion(FinanceEntry(date: Date(), snapshot: Self.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FinanceEntry>) -> Void) {
        let entry = FinanceEntry(date: Date(), snapshot: Self.load())
        let refresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
}

// MARK: - Views

struct FinanceWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: FinanceEntry

    private var snapshot: WidgetSnapshot { entry.snapshot }

    var body: some View {
        Group {
            if family == .systemMedium {
                mediumView
            } else {
                smallView
            }
        }
        .containerBackground(for: .widget) {
            Color(red: 0.039, green: 0.369, blue: 0.314) // ftTealDeep emerald
        }
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("SAFE TO SPEND")
                .font(.caption2).bold()
                .foregroundStyle(.white.opacity(0.75))
            Text(widgetMoney(snapshot.safeToSpend))
                .font(.title2).bold()
                .foregroundStyle(.white)
                .minimumScaleFactor(0.6)
            Text("Net worth \(widgetMoney(snapshot.netWorth))")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.85))
            Spacer(minLength: 2)
            Text("Next: \(snapshot.nextBillName) · \(widgetMoney(snapshot.nextBillAmount))")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var mediumView: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SAFE TO SPEND")
                    .font(.caption2).bold()
                    .foregroundStyle(.white.opacity(0.75))
                Text(widgetMoney(snapshot.safeToSpend))
                    .font(.title).bold()
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.6)
                Text("Net worth \(widgetMoney(snapshot.netWorth))")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
            }
            Spacer()
            VStack(alignment: .leading, spacing: 4) {
                Text("NEXT BILL")
                    .font(.caption2).bold()
                    .foregroundStyle(.white.opacity(0.75))
                Text(snapshot.nextBillName)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(widgetMoney(snapshot.nextBillAmount))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                Text(snapshot.nextBillDay > 0 ? "Due day \(snapshot.nextBillDay)" : "")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Widget definition

struct FinanceWidget: Widget {
    let kind = "FinanceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FinanceProvider()) { entry in
            FinanceWidgetView(entry: entry)
        }
        .configurationDisplayName("Finance Tracker")
        .description("Safe to spend, net worth and your next bill.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct FinanceWidgetsBundle: WidgetBundle {
    var body: some Widget {
        FinanceWidget()
    }
}
