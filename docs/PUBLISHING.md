# Publishing Finance Tracker — Apple checklist

House standard: merge to `main` → CI archives → TestFlight automatically.
The final public App Store **Submit stays Parthey's tap** — merge-to-main
can never publish publicly by itself (Apple review sits in between).

## Already done by Alfred ✅
- [x] Native SwiftUI skeleton, bundle `com.parthey.financetracker`, v1.0 (1)
- [x] App icon (1024px) + AccentColor + `PrivacyInfo.xcprivacy` (Data Not Collected)
- [x] Export compliance pre-answered in the project:
      `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO`
      (the app uses only Apple's standard, exempt encryption — so future
      builds skip the per-build "Missing Compliance" hold that bit Work Spots)
- [x] `ios-build.yml` — unsigned compile check on macos-26 / Xcode 26
- [x] `release.yml` — proven Work Spots flow: unsigned archive → signed
      export via API key → TestFlight upload. Until the secrets below exist
      it dry-runs (unsigned build + warning) and lights up automatically
      on the first merge after they land.
- [x] GitHub deploy key added by Parthey (2026-11-26) — Alfred can push.

## Owner-only gates — Parthey (Apple requires the account holder)

Status update 2026-11-26: Bundle ID `com.parthey.financetracker` registered
and the App Store Connect record created by Parthey. GitHub secrets added by Parthey 2026-11-26 — signed TestFlight path is live.

### 1. App Store Connect record (~2 min)
App Store Connect → Apps → "+" → New App:
- Platform: iOS
- Name: **Finance Tracker** — check this FIRST; if taken, fallbacks in order:
  **Private Finance Tracker**, **My Finance Tracker**. Tell Alfred which landed.
- Primary language: English (U.S.)
- Bundle ID: `com.parthey.financetracker`
  (if not in the dropdown: developer.apple.com → Certificates, Identifiers
  & Profiles → Identifiers → "+" → App IDs → App → description
  "Finance Tracker", Explicit ID `com.parthey.financetracker`, no
  capabilities → Register)
- SKU: `financetracker-ios-001`
- User Access: Full Access

### 2. GitHub repo secrets — reuse the SAME "Alfred CI" key as Work Spots
Repo → Settings → Secrets and variables → Actions → add the same 4 values
already used in wfh-spots-tracker (no new API key needed):
- `ASC_KEY_ID`
- `ASC_ISSUER_ID`
- `ASC_KEY_P8` (full contents of the .p8 file)
- `ASC_TEAM_ID` — `88PR54354Q`

### 3. TestFlight internal group (once, after the record exists)
App Store Connect → Finance Tracker → TestFlight → Internal Testing →
create group `Internal-pk`, add yourself. Later builds distribute to it
automatically; export compliance is already handled (see above).

## After the gates
- Next merge to `main` uploads Build 1 to TestFlight (Apple processing
  ~15–30 min, then Update appears in the TestFlight app).
- Design iterations: Parthey directs design from Muse chat on his phone,
  Alfred edits, pushes, CI ships a new TestFlight build each merge.
- Public listing (later, Parthey's call): categories Finance / Productivity,
  privacy = Data Not Collected, price / distribution decided then.
