# Feature Parity — Finance Tracker vs the paid apps

Checked 2026-11-26 against the current paid market. This is an honest
matrix, not marketing: where we deliberately do **not** match a paid app,
it says so and why.

**Our key:** `Have` = in the working prototype today · `Wireframe` = in
this design round (see wireframes) · `Planned` = agreed, later round ·
`Won't do` = excluded by design (privacy promise in `PRIVACY.md`)

Prices for context: Simplifi $3.99–$6.99/mo · Monarch $99.99/yr Core,
$199.99 Plus · YNAB $109/yr · Copilot $109/yr · Rocket Money free + paid
bill-negotiation fees. Ours: **free, no subscription.**

| Feature | Simplifi | Monarch | YNAB | Copilot | Rocket | Ours |
|---|---|---|---|---|---|---|
| Dashboard / net worth | ✅ | ✅ | basic | ✅ | ✅ | **Have** |
| Accounts (manual + balances) | ✅ | ✅ | ✅ | ✅ | ✅ | **Have** |
| Transaction ledger, search/filter | ✅ | ✅ | ✅ | ✅ | ✅ | **Have** |
| Spending Plan (income − bills − goals = safe-to-spend) | ✅ signature | partial | zero-based instead | adaptive | ❌ | **Wireframe** |
| Budgets by category | ✅ | ✅ | ✅ (zero-based) | ✅ adaptive | basic | **Have** |
| Rollover budgets | ✅ | ✅ | ✅ | ✅ | ❌ | **Wireframe** |
| View / plan future months | ✅ (12 mo) | ✅ | ✅ | partial | ❌ | **Wireframe** |
| Projected cash flow | ✅ up to 12 mo | partial | ❌ | partial | ❌ | **Wireframe** (mini-chart + upcoming) — full 12-mo view **Planned** |
| Savings goals | ✅ in plan | ✅ | targets | ✅ | ✅ | **Have** |
| Goals inside the spending plan | ✅ | partial | targets | partial | ❌ | **Wireframe** |
| Watchlists (category / tag / merchant) | ✅ | partial | ❌ | partial | ❌ | **Wireframe** |
| Recurring bills & subscriptions detection | ✅ | ✅ | ✅ | ✅ | ✅ signature | **Wireframe** |
| Credit card in plan (statement / min due / due date) | ✅ Bill Connect | ✅ | ✅ | ✅ | ✅ | **Wireframe** (manual statement entry — no Bill Connect, see below) |
| Auto-categorisation | ✅ | ✅ | ✅ | ✅ + AI | ✅ | **Wireframe** (on-device rules from your own history; no cloud AI) |
| Split transactions, pending, tags, notes | ✅ | ✅ | ✅ | ✅ | partial | **Wireframe** |
| Custom categories | ✅ | ✅ | ✅ | ✅ | ✅ | **Have** |
| Reports (category breakdown, trends, net worth over time) | ✅ | ✅ | ✅ | ✅ | basic | **Wireframe** |
| Tax reporting / export for taxes | ✅ | partial | ❌ | ❌ | ❌ | **Planned** (CSV export already Have) |
| Customisable dashboard | ✅ | ✅ | partial | ✅ | ❌ | **Planned** |
| Import from other apps / banks (CSV, OFX/QFX/QIF) | ✅ CSV in | ✅ CSV in | ✅ CSV in | ❌ no import | ❌ | **Wireframe** — see `MIGRATION.md` |
| Export your data (CSV / JSON) | ✅ CSV | ✅ CSV | ✅ CSV | ✅ CSV | partial | **Have** (+ encrypted backup) |
| Encrypted local vault, no account | ❌ cloud account | ❌ | ❌ | ❌ | ❌ | **Have — our differentiator** |
| Household / partner sharing | partial | ✅ unlimited | ✅ up to 6 | coming soon | ❌ | **Planned** (via encrypted file share only — no cloud accounts) |
| Investment tracking | ✅ | ✅ | basic | ✅ | ✅ | **Planned** (manual holdings / balances first; no live prices without a data feed decision) |
| Live bank sync (14,000+ institutions) | ✅ | ✅ | ✅ | ✅ | ✅ | **Won't do — by design.** Requires Plaid/aggregator + a server + your bank credentials leaving the device. Breaks the privacy promise. Our answer is file import (CSV/OFX/QFX) read on-device. Any future aggregator is opt-in, off by default, and needs an explicit owner decision — see `MIGRATION.md`. |
| Credit score monitoring | ✅ | partial | ❌ | ❌ | ✅ | **Won't do — by design.** Requires a credit-bureau data feed and identity data on a server. Out of scope for a local-only app. |
| Retirement planner | ✅ (15 variables) | partial | ❌ | ❌ | ❌ | **Won't do for v1 / Later at best.** A credible planner is a product of its own; a bad one is worse than none. Revisit after core parity ships. |
| Bill negotiation / subscription cancellation service | ❌ | ❌ | ❌ | ❌ | ✅ signature | **Won't do — by design.** Requires acting on the user's accounts with third parties and sharing their bills with a service. We *detect* subscriptions (Wireframe); cancelling stays the user's tap in the provider's own app. |
| AI assistant (chat about your money) | partial | ✅ | ❌ | ✅ beta | partial | **Planned — on-device only if/when it ships.** No sending financial data to a cloud model. |
| Native iOS app | ✅ | ✅ | ✅ | ✅ | ✅ | **Have** (skeleton, TestFlight pipeline live) |
| Android / Web | ✅ | ✅ | ✅ | ❌ no Android | ✅ | **Planned** (web prototype exists; Android later) |

## Gaps we are closing in this design round

1. **Spending Plan as the home number** — safe-to-spend (income − bills −
   goals), not just category budgets. With rollover toggles and a
   future-month switcher.
2. **Projected cash flow (starter)** — dashboard mini-chart from recurring
   income/bills already in the app. Full 12-month projection is Planned.
3. **Watchlists** — category / merchant watch with progress, alongside budgets.
4. **Recurring & subscription finder** — detected from imported/manual
   history, shown as upcoming bills with due dates.
5. **Credit cards done properly, manually** — statement balance, minimum
   due and due date entered per card (or read from an imported statement
   CSV), feeding the Spending Plan — without Bill Connect / bank login.
6. **Auto-categorisation, on-device** — rules learned from the user's own
   corrections, plus split / pending / tags in the ledger.
7. **Reports** — category donut, month trends, net-worth-over-time.
8. **Migration wizard** — import from Simplifi / Monarch / YNAB / Copilot /
   bank files with mapping, preview and dedupe (see `MIGRATION.md`).

## Deliberately not closing (owner-visible)

Bank sync, credit score, bill negotiation/cancellation, and a retirement
planner — reasons in the matrix above. These are the price of "no account,
no server, no data leaves the device." If that trade-off ever changes, it
is an explicit owner decision recorded here first, not a silent feature.
