# Migration — getting your data in

Two paths in, both **file-based and read entirely on your device**.
Nothing is uploaded anywhere; there is no bank login in this app.

- **Path A — from another finance app:** export a CSV there, import it here.
- **Path B — from your bank:** download transactions (CSV, or better
  OFX/QFX/QIF) from your bank's website, import the file here.

> Why not "connect my bank" like Simplifi/Monarch? Those use an aggregator
> (Plaid etc.) plus a cloud server. Our privacy promise (`PRIVACY.md`) rules
> that out by default. An optional aggregator would break that promise and
> needs an explicit owner decision before it is ever designed — it is
> **not** the default and not in this design.

---

## Path A — export from your old app

### Quicken Simplifi
1. Open Simplifi in a **web browser** (export is web-only, CSV only).
2. Go to **Transactions**.
3. Click **Export / Download CSV**. Repeat per account if prompted.
4. Import each file here (wizard below), choosing that account.

### Monarch Money
1. Open Monarch on the web.
2. **Settings → Data → Download transactions** for a full CSV.
   (Monarch suggests ~5,000 transactions per file — split long histories
   by date range and import the files one after another; dedupe handles
   overlaps.)
3. Per-account instead: open the account → **Edit → Download transactions**.

### YNAB
1. Open YNAB on the web.
2. Click your **plan name** (top of the left sidebar) → **Export Plan**.
   You get two CSVs: categories and transactions. Import the
   **transactions** file here; keep the categories file for reference.
3. Per-account: open the account, select transactions → **More → Export**.
4. Note: YNAB **targets and category notes do not export** — jot down any
   you want to recreate (the checklist at the end helps).

### Copilot Money
1. On **iPhone**: Settings → Account → **Export your transactions**
   (full CSV, share/save it to Files).
2. On **iPad / Mac / web**: filter the **Transactions** tab to what you
   want, then export that view.
3. Note: Copilot itself offers no CSV *import* — leaving it is one-way,
   which is exactly why our import accepts its CSV as-is.

### Rocket Money
There is no meaningful CSV export of full history and no CSV import —
history generally **cannot** be migrated automatically. Workaround:
download statements/transactions from each underlying **bank** instead
(Path B) and import those.

### Quicken Classic / Mint-era files / spreadsheets
QIF, OFX/QFX and plain CSV are all accepted by the wizard. A spreadsheet
works if it has at least a Date and an Amount column.

---

## Path B — download from your bank

On your bank's **website** (mobile apps often hide this), look for
**Statements / Download transactions / Export** on the account page.
Menus vary, typically like:

- **Chase:** account → Download account activity → choose date range →
  file type **CSV** (or Quicken **QFX** where offered).
- **Bank of America:** account → Statements & Documents / Download →
  choose period → **CSV** or Quicken format.
- **Wells Fargo:** account → Download Account Activity → date range →
  **Comma Delimited (CSV)** or Quicken **QFX**.
- **Citi:** account → Download Transactions → date range → **CSV** or
  Quicken/QuickBooks format.

**Prefer OFX/QFX when offered** — it carries clean dates, amounts and
payee names and needs no column mapping. CSV is fine; the wizard maps it.
Download **one account at a time** and import into the matching account
here — that is what keeps balances and dedupe correct.

---

## Our import wizard (in the wireframes)

1. **Choose source** — Simplifi / Monarch / YNAB / Copilot / Bank file /
   Other CSV. Known sources pre-map their known columns.
2. **Pick the file & target account** — file is read on-device only.
3. **Map columns** — Date / Description / Amount / Category (and
   Debit/Credit split if the file uses two columns). Auto-detected first,
   manually fixable. Handles quoted commas, `$` and parenthesised
   amounts, `MM/DD/YYYY` and ISO dates.
4. **Preview & dedupe** — every row shown before anything is saved;
   likely duplicates (same date + amount + description as an existing
   transaction) are flagged and **skipped by default**; unreadable rows
   are flagged with the reason.
5. **Done** — summary: imported / skipped duplicates / needs review.
   Imported rows immediately update balances, budgets, Spending Plan,
   recurring detection and reports.

## What does and doesn't carry over

| Thing | Carries over? |
|---|---|
| Transactions (date, description, amount) | ✅ Yes |
| Categories on those transactions | ✅ Mostly — mapped to your categories; unknown ones are created or sent to "Needs review", your choice in the wizard |
| Account names / starting balances | ⚠️ Partially — create the account here first (or in the wizard); set its current balance; history then builds from there |
| Budgets | ❌ No app exports them in an importable form — recreate in the Spending Plan (guided checklist below) |
| Savings goals | ❌ Recreate — name, target, date (checklist) |
| Recurring bills / subscriptions | ⚠️ Detected automatically from imported history after import — confirm the list rather than re-typing it |
| Watchlists, rules, tags | ❌ Recreate (tags on transactions may survive if the CSV has a Tags column) |
| Investment holdings | ❌ Not in transaction CSVs — planned as manual holdings later |

## Guided "finish your move" checklist (shown after first import)

- [ ] All accounts created, balances match your old app today
- [ ] History imported per account, duplicates skipped
- [ ] Categories reviewed (Needs-review bucket emptied)
- [ ] Spending Plan rebuilt: income, bills, budget amounts
- [ ] Goals recreated with targets/dates
- [ ] Recurring list confirmed; credit cards' statement/min-due/due-date set
- [ ] Encrypted backup exported and saved somewhere safe — your old app
      can now be cancelled
