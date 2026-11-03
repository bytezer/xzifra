# Xzifra

A simple, local-first expense tracker for Android. Record what you spend, see
where it goes, and keep everything on your device — no accounts, no cloud, no
budgets.

## Features

- **Quick entry** — amount first with a large keypad, then category and payment
  method. Two taps to record an expense.
- **Your own categories** — create, rename, recolor, reorder, archive. Categories
  with expenses are archived instead of deleted, so history never breaks.
- **Payment methods** — cash, Yape, Plin, debit, credit and bank transfer, plus
  any custom ones you add.
- **PEN and USD** — totals are always kept separate per currency. No exchange
  rates, no hidden conversions.
- **Reports** — spending by category, last 12 months, and by payment method, with
  a month selector.
- **Local-first** — everything lives in a SQLite database on the device. The app
  works offline and has no backend.
- **Backup** — export a full JSON backup or a CSV for spreadsheets, and import a
  JSON backup to restore or merge.

## Stack

| Layer | Choice |
| --- | --- |
| Framework | Flutter (Material 3) |
| State | Riverpod |
| Database | Drift (SQLite) with reactive queries |
| Navigation | go_router |
| Charts | fl_chart |
| Formatting | intl (`en_US`, PEN/USD) |

## Requirements

- Flutter 3.47+ and Dart 3.13+
- Android SDK 36 and JDK 17
- An Android device with USB debugging enabled (or wireless ADB)

The project expects a toolchain at `../.toolchains` (Flutter, JDK and Android
SDK), matching the sibling projects in this workspace. Override it with
`XZIFRA_TOOLCHAIN`.

## Development

```bash
cd app
flutter pub get
dart run build_runner build   # regenerate Drift code after schema changes
flutter run                   # hot reload on the connected device
```

Quality checks:

```bash
flutter analyze
flutter test
```

## Build a release APK

```bash
./scripts/build-apk.sh
```

Output: `app/build/app/outputs/flutter-apk/app-release.apk`

The default build is a universal APK (~60 MB) that works on any device. For a
smaller, ABI-specific APK (arm64 only, ~25 MB):

```bash
./scripts/build-apk.sh --split-per-abi
```

Outputs land in `app/build/app/outputs/flutter-apk/` as `app-arm64-v8a-release.apk`,
`app-armeabi-v7a-release.apk` and `app-x86_64-release.apk`.

Install it on a connected device:

```bash
adb install -r app/build/app/outputs/flutter-apk/app-release.apk
```

`-r` keeps the existing app data. See [docs/signing.md](docs/signing.md) before
rebuilding — the signing key must be kept safe.

## Project structure

```
app/lib/
  core/        theme and shared widgets
  data/        Drift schema, queries, seed, export/import
  domain/      money, periods and report math (pure Dart, tested)
  features/    dashboard, expenses, reports, settings
  routing/     go_router configuration and app shell
app/test/      unit and database tests
scripts/       build-apk.sh
docs/          signing notes
```

## Data and backups

The database is stored in the app's private storage. Uninstalling the app deletes
it, so keep a JSON backup somewhere safe:

**Settings → Backup → Export JSON backup** shares the file through the Android
share sheet (Drive, email, etc.). **Import JSON backup** merges a backup back in;
existing records win on conflict.

## Out of scope

Budgets, income tracking, account balances, bank sync, recurring expenses, receipt
photos, multi-user support and cloud sync.
