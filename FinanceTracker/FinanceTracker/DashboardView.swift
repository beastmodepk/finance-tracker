import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var store: Store

    private var lowPoint: CashPoint? {
        store.projectedCashFlow.min { $0.balance < $1.balance }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    // Safe-to-spend hero (owner default: this IS the hero number)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("SAFE TO SPEND · THIS MONTH")
                            .font(.caption).bold().foregroundStyle(.white.opacity(0.75))
                        Text(money(store.safeToSpend))
                            .font(.system(size: 34, weight: .bold)).foregroundStyle(.white)
                        Text("Income \(money(store.expectedMonthlyIncome)) − Bills \(money(store.monthlyBillsTotal)) − Goals \(money(store.monthlyGoalContributions)) − Spent \(money(store.spentThisMonth))")
                            .font(.caption).foregroundStyle(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.ftTealDeep)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Net worth").font(.subheadline).foregroundStyle(.secondary)
                            Text(money(store.netWorth)).font(.title3).bold()
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Assets \(money(store.totalAssets))").font(.caption).foregroundStyle(.secondary)
                            Text("Debts \(money(store.totalDebts))").font(.caption).foregroundStyle(.secondary)
                            Text("Savings rate \(Int(store.savingsRate * 100))%").font(.caption).bold().foregroundStyle(Color.ftTealText)
                        }
                    }
                    .padding()
                    .background(Color.ftCream)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Projected cash flow — next 90 days").bold()
                        Chart(store.projectedCashFlow) { point in
                            LineMark(x: .value("Date", point.date), y: .value("Balance", point.balance))
                                .foregroundStyle(Color.ftTeal)
                            PointMark(x: .value("Date", point.date), y: .value("Balance", point.balance))
                                .foregroundStyle(Color.ftAmber)
                                .symbolSize(point.balance == (lowPoint?.balance ?? -1) ? 60.0 : 0.0)
                        }
                        .frame(height: 130)
                        if let low = lowPoint {
                            Text("Low point \(money(low.balance)) on \(low.date.shortDay) — plan big bills around it.")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.ftCream)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Upcoming bills").bold().padding(.bottom, 2)
                        ForEach(store.upcomingRecurring.prefix(4)) { item in
                            HStack {
                                Text(item.name)
                                Spacer()
                                Text("\(item.dayOfMonth == Calendar.current.component(.day, from: Date()) ? "Today" : "Day \(item.dayOfMonth)") · \(money(abs(item.amount)))")
                                    .foregroundStyle(.secondary)
                            }
                            .font(.subheadline)
                            Divider()
                        }
                    }
                    .padding()
                    .background(Color.ftCream)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
}
