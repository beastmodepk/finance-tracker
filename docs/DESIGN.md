# Design

Status: **OPEN — to be finalised with the owner next.**
This file records what is settled and what is still a decision, so design
work starts from facts, not guesses.

## Settled

- Original design language — not a clone of Quicken Simplifi's UI, layout,
  wording, or branding. Concepts only: dashboard, spending plan, watchlist.
- Privacy-first (see PRIVACY.md) shapes the design: no sign-up flow,
  no "connect your bank" CTA, vault create / unlock is the entry point.
- Core screens (from the working Muse prototype):
  1. Dashboard — net worth, cash flow, savings rate, category donut,
     6-month cash flow
  2. Transactions — searchable / filterable ledger, add + CSV import
  3. Accounts — manual accounts and balances
  4. Spending Plan — budgets by category with progress
  5. Goals — savings goals with quick contributions
  6. Watchlist — bills / items needing attention
  7. Vault — lock, change passphrase, wipe, encrypted backup export/import
- Demo data on first use must be clearly labelled, with one-tap
  "Clear & start fresh".

## Open questions (owner decision needed)

- [ ] Final name / branding for the standalone app (working name: Finance Tracker)
- [ ] Visual direction for the standalone version — keep the prototype's
      look, or a new direction?
- [ ] Target form first: web (PWA) only, or web + native wrapper?
- [ ] Tech stack for the standalone repo (prototype is a single-file web app)
- [ ] Recurring bills / transactions — in v1 of the standalone, or v1.1?
- [ ] Category set: fixed starter set, fully custom, or both?
- [ ] Multi-currency — needed, or USD only for now?

## Workflow

1. Design is agreed in the Muse prototype first and shown to the owner.
2. Only approved design is ported here.
3. One commit per feature — never bundle unrelated features.
