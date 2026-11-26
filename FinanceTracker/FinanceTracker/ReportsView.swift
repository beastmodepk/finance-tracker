import SwiftUI
import Charts

private struct CategorySlice: Identifiable {
    var id: String { category }
    let category: String
    let total: Double
}

private struct MonthRow: Identifiable {
    var id: String { month }
    let month: String
    let spent: Double
    let income: Double
}

private struct WorthRow: Identifiable {
    var id: String { month }
    let month: String
    let value: Double
}

struct ReportsView: View {
    @EnvironmentObject var store: Store

    private var slices: [CategorySlice] {
        store.spendingByCategory.map { CategorySlice(category: $0.category, total: $0.total) }
    }
    private var totalSpent: Double { slices.reduce(0) { $0 + $1.total } }
    private var monthlyTrend: [MonthRow] {
        [MonthRow(month: "Jun", spent: 2210, income: 4850),
         MonthRow(month: "Jul", spent: 2480, income: 4850),
         MonthRow(month: "Aug", spent: 2090, income: 4850),
         MonthRow(month: "Sep", spent: 2340, income: 4850),
         MonthRow(month: "Oct", spent: 2260, income: 4850),
         MonthRow(month: "Nov", spent: store.allSpendingThisMonth, income: store.incomeThisMonth)]
    }
    private var netWorthSeries: [WorthRow] {
        [WorthRow(month: "Jun", value: 31900), WorthRow(month: "Jul", value: 33400),
         WorthRow(month: "Aug", value: 34800), WorthRow(month: "Sep", value: 36100),
         WorthRow(month: "Oct", value: 37200), WorthRow(month: "Nov", value: store.netWorth)]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Spending by category · \(money(totalSpent))").bold()
                    Chart(slices) { slice in
                        SectorMark(angle: .value("Spent", slice.total), innerRadius: .ratio(0.55), angularInset: 1.5)
                            .foregroundStyle(by: .value("Category", slice.category))
                    }
                    .frame(height: 190)
                    ForEach(slices) { slice in
                        HStack {
                            Text(slice.category)
                            Spacer()
                            Text("\(money(slice.total)) · \(totalSpent > 0 ? Int(slice.total / totalSpent * 100) : 0)%")
                                .foregroundStyle(.secondary)
                        }
                        .font(.caption)
                    }
                }
                .reportCard()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Trend — spending (teal) vs income (amber)").bold()
                    Chart(monthlyTrend) { row in
                        BarMark(x: .value("Month", row.month), y: .value("Spent", row.spent))
                            .foregroundStyle(Color.ftTeal)
                            .position(by: .value("Kind", "Spent"))
                        BarMark(x: .value("Month", row.month), y: .value("Income", row.income))
                            .foregroundStyle(Color.ftAmber)
                            .position(by: .value("Kind", "Income"))
                    }
                    .frame(height: 150)
                    Text("Avg income \(money(4850)) · this month so far \(money(store.allSpendingThisMonth)) spent")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .reportCard()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Net worth over time").bold()
                    Chart(netWorthSeries) { row in
                        LineMark(x: .value("Month", row.month), y: .value("Net worth", row.value))
                            .foregroundStyle(Color.ftTealDeep)
                        AreaMark(x: .value("Month", row.month), y: .value("Net worth", row.value))
                            .foregroundStyle(Color.ftTealSoft)
                    }
                    .chartYScale(domain: 28000...42000)
                    .frame(height: 140)
                    Text("\(money(31900)) → \(money(store.netWorth)) in 6 months")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .reportCard()

                VStack(spacing: 6) {
                    HStack { Text("Savings rate").bold(); Spacer(); Text("\(Int(store.savingsRate * 100))%").bold() }
                    HStack { Text("Top category"); Spacer(); Text(slices.first?.category ?? "—") }
                    HStack { Text("Tax export"); Spacer(); Text("CSV ›").foregroundStyle(Color.ftTealDeep) }
                }
                .font(.subheadline)
                .reportCard()
            }
            .padding()
        }
        .navigationTitle("Reports")
    }
}

private extension View {
    func reportCard() -> some View {
        self.padding()
            .background(Color.ftCream)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
