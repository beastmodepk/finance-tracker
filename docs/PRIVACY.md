# Privacy & Encryption

This document is the contract. If code ever conflicts with it, the code is wrong.

## Data model

- All user data (accounts, transactions, budgets, goals, bills) is stored
  **only on the user's device**.
- There is no server, database, analytics endpoint, or third-party SDK
  that receives financial data.
- The app works offline after first load.

## Encryption at rest

- Algorithm: **AES-256-GCM** via the browser Web Crypto API.
- Key derivation: **PBKDF2** from a user-chosen passphrase, with a fresh
  random salt when the vault is created and when the passphrase changes.
- Every save re-encrypts the whole vault; plaintext is never written to
  local storage, disk, or a network request.
- Locking the app discards the in-memory key. Reopening requires the passphrase.
- Wrong passphrase = decryption fails and is rejected; there is no recovery
  back-door. Losing the passphrase means losing the vault — say so plainly in UI.

## Imports & exports

- **Bank CSV import:** the file is read entirely in-browser. It is never
  uploaded. The parser handles quoted commas, `$` / parenthesised amounts,
  `MM/DD/YYYY` and ISO dates, and duplicate detection.
- **Encrypted backup:** a password-encrypted file the user downloads and
  can re-import. This is the supported way to move between devices.
- **Plain CSV / JSON export:** available only on explicit user action, with
  a clear warning that the resulting file is unencrypted.

## What must never be added

- Bank-login aggregation (Plaid or similar)
- Advertising, analytics, crash-reporting that includes financial data
- Cloud sync that stores plaintext (any future sync must be end-to-end
  encrypted, opt-in, and documented here first)
- Real user financial data in this repository, issues, or screenshots
