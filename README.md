# Finance Tracker

A free, privacy-first personal finance app — inspired by the *ideas* in
tools like Quicken Simplifi (dashboard, spending plan, watchlists), but
an original design and codebase. Not a copy, and not affiliated with
Quicken, Inc.

Built so you don't have to pay a subscription to see your own money.

## Privacy promise (non-negotiable)

- **No account.** No sign-up, no email, no login with a third party.
- **No bank connection.** No Plaid, no credential sharing, no aggregator.
- **No server.** There is no backend collecting your data.
- **No analytics / tracking.** Nothing phones home.
- **Local-only, encrypted at rest.** Your data lives on your device in an
  encrypted vault (AES-256-GCM, key derived from your passphrase with
  PBKDF2 via the Web Crypto API). Closing / locking the app locks the vault.
- **Your exports, your choice.** Encrypted backup files for moving between
  devices; plain CSV / JSON export only when you explicitly ask for it.
- **Never commit real financial data to this repo.** See `.gitignore` —
  vault files, bank CSVs, and exports are blocked by default.

## What it does (v1, in the Muse app)

- Dashboard: net worth, cash flow, savings rate
- Spending by category + 6-month cash-flow view
- Searchable / filterable transaction ledger
- Accounts (checking, savings, credit cards, cash) — manual balances
- Spending Plan / budgets by category
- Savings goals with quick contributions
- Watchlist: bills / items needing attention
- Bank CSV import (read entirely in-browser, column mapping, duplicate skip)
- Encrypted local vault: create passphrase, auto-save encrypted,
  lock screen, change passphrase, wipe vault

Live prototype: the Muse app **Private Finance Tracker**
(slug `private-finance-tracker`). Design is being finalised there first;
this repo is the public home for the standalone version.

## Status

**Repo-ready / design phase — 2026-11-26**

Repo scaffolding, privacy model, and design docs are in place.
Final UI design and the standalone code layout are the next step,
agreed with the owner before code is ported from the prototype.

See:
- [docs/PRIVACY.md](docs/PRIVACY.md) — encryption & data model
- [docs/DESIGN.md](docs/DESIGN.md) — principles + open design questions
- [docs/ROADMAP.md](docs/ROADMAP.md) — planned order of work

## Principles

1. Privacy first — if a feature needs a server, it doesn't ship.
2. Original design — borrow concepts, never copy UI, copy, or code.
3. Small commits — one commit per feature / functionality.
4. No real data in git — ever.

## Owner

Parthey Khanderia — [@beastmodepk](https://github.com/beastmodepk)
