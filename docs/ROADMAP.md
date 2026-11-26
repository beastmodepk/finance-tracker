# Roadmap

## Phase 0 — Repo ready ✅ (2026-11-26)
- [x] Repo created: `beastmodepk/finance-tracker` (public, empty at start)
- [x] README with privacy promise and status
- [x] `.gitignore` blocking vaults, bank CSVs, exports, and secrets
- [x] Privacy / encryption contract (`docs/PRIVACY.md`)
- [x] Design doc with settled points + open questions (`docs/DESIGN.md`)

## Phase 1 — Finalise design (next)
- [ ] Owner answers the open questions in DESIGN.md
- [ ] Prototype updated to the agreed design and approved by owner
- [ ] Standalone tech stack chosen and recorded in DESIGN.md

## Phase 2 — Standalone build
- [ ] Scaffold app in `src/` per the chosen stack
- [ ] Port vault (AES-256-GCM + PBKDF2, lock / unlock / wipe)
- [ ] Port dashboard, ledger, accounts, budgets, goals, watchlist
- [ ] Port CSV import + encrypted backup export/import
- [ ] Verify: no network calls carrying financial data, offline works

## Phase 3 — Polish
- [ ] Recurring bills (if not in Phase 2)
- [ ] PWA install / offline polish (if web is the chosen form)
- [ ] Release checklist + screenshots with demo data only
