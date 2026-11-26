import SwiftUI

struct RecurringView: View {
    @EnvironmentObject var store: Store

    private var subscriptions: [RecurringItem] { store.recurring.filter { $0.isSubscription } }
    private var subscriptionMonthly: Double { abs(subscriptions.reduce(0) { $0 + $1.amount }) }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("COMMITTED EACH MONTH").font(.caption).bold().foregroundStyle(.white.opacity(0.75))
                    Text(money(store.monthlyBillsTotal)).font(.title).bold().foregroundStyle(.white)
                    Text("\(store.recurring.filter { $0.amount < 0 }.count) recurring charges from your history")
                        .font(.caption).foregroundStyle(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .listRowBackground(Color.ftTealDeep)
            }
            Section("Upcoming") {
                ForEach(store.upcomingRecurring.prefix(6)) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Text("Day \(item.dayOfMonth) · \(money(abs(item.amount)))")
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
            }
            Section("Subscription finder") {
                ForEach(subscriptions) { item in
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(item.name)
                            Spacer()
                            if item.priceRose, let previous = item.previousAmount {
                                Text("\(money(abs(previous))) → \(money(abs(item.amount)))").bold()
                            } else {
                                Text("\(money(abs(item.amount)))/mo").bold()
                            }
                        }
                        .font(.subheadline)
                        if item.priceRose {
                            Text("Price rose").font(.caption).bold().foregroundStyle(.red)
                        }
                        if item.looksUnused {
                            Text("Unused? No activity logged").font(.caption).bold().foregroundStyle(Color.ftAmber)
                        }
                    }
                }
                Text("Total subscriptions: \(money(subscriptionMonthly))/mo · \(money(subscriptionMonthly * 12))/yr. We flag them — cancelling happens in each provider's own app; we never act on your accounts.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Recurring")
    }
}
