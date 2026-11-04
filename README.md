# Xzifra

A local-first personal records app for Android. Track expenses, capture notes and
bookmarks, set reminders and keep recurring payments under control — all on your
device, with no accounts, no cloud and no analytics.

## Features

- **Records hub** — four tabs under **Records**: expenses, notes, bookmarks and
  reminders.
- **Quick entry** — record an expense with a large keypad, category and payment
  method. Templates, duplicate and repeat-last speed up repeat purchases.
- **Notes** — title, plain text or Markdown source, tags, pin, archive and
  delete. Export one note as Markdown or every note as a ZIP for Obsidian.
- **Bookmarks** — save URLs with a title, note and tags. Links open in the
  external browser; validation only accepts `http` and `https`. Export all
  bookmarks as Markdown in a ZIP for Obsidian.
- **Reminders** — title, note, due date/time and tags. Sections for overdue,
  today, upcoming and done. Done/undone, edit and delete.
- **Recurring expenses** — rent, subscriptions and other regular payments.
  Register or skip occurrences manually; Xzifra never creates expenses in the
  background.
- **Attachments** — add camera/gallery images or PDF/image documents to saved
  expenses, notes and reminders. Files stay in app-private storage.
- **Global search** — search expenses, notes and bookmarks from Home or the
  Records app bar.
- **Your own categories and payment methods** — create, rename, recolor,
  reorder, archive. Categories with history are archived instead of deleted.
- **PEN and USD** — totals stay separate per currency. No exchange rates.
- **Reports** — spending by category, last 12 months and payment method.
- **Local-first** — SQLite on the device. No backend and no network access.
- **Backups** — JSON for data, CSV for spreadsheets, and a full ZIP backup that
  also includes attachments.
- **Themes** — Indigo (light/dark) and Cyber Red (black surfaces, neon red,
  dark only).
- **English and Spanish** — follows the device language or can be switched in
  **Settings → Language**.
- **Launcher shortcuts** — new expense, reports, new note and new reminder.
- **Home-screen widget** — current month total, next upcoming item and a
  one-tap `+` button.
- **About** — version, build, commit and branch, diagnostics and licenses.

## Records hub

The bottom navigation has four destinations: **Home**, **Records**, **Reports**
and **Settings**. Records contains:

| Tab | What it stores |
| --- | --- |
| Expenses | Amount, currency, date, category, payment method and note |
| Notes | Title, Markdown/plain body, tags, pinned/archive state |
| Bookmarks | URL, title, note and tags |
| Reminders | Title, note, due date/time and tags |

Use the floating **+** button for quick capture and choose **Expense**, **Note**,
**Bookmark** or **Reminder**.

Global search covers expenses, notes and bookmarks. Archived notes and bookmarks
are intentionally excluded from global search.

## Recurring expenses

A recurring rule stores a name, amount, currency, category, optional payment
method, frequency (daily, weekly, monthly or yearly), interval, next date,
optional end date and note.

When `nextDate` is today or earlier the rule is **due**. From the Recurring page
or the Home card you can:

- **Register** — create one expense dated at `nextDate`, linked to the rule, and
  advance `nextDate` by one occurrence.
- **Skip** — advance `nextDate` without creating an expense.

If several periods are overdue, the rule stays due after one registration so you
can catch up one period at a time. Xzifra **does not auto-create expenses**.
Month-end dates clamp correctly (Jan 31 + 1 month → Feb 28/29; Feb 29 + 1 year →
Feb 28).

## Reminders and notifications

Reminders are grouped into Overdue, Today, Upcoming and Done. Saving a reminder
schedules a local notification at its due time.

- Notifications use **inexact** scheduling (`inexactAllowWhileIdle`), so Android
  may deliver them a little late or batch them. This avoids requesting exact-alarm
  permissions.
- Android 13+ asks for notification permission when you save your first reminder.
  If you deny it, the reminder is still saved but will not notify.
- Pending reminders are rescheduled when the app starts. Completing or deleting a
  reminder cancels its notification.
- Tapping a notification opens that reminder in the editor.
- Recurring expenses do not send notifications; they appear in the app and on
  Home.

## Attachments

Attachments are available on saved expenses, notes and reminders (edit mode).
Use the paperclip section to add:

- a photo from the camera or gallery (downscaled/compressed by `image_picker`), or
- a PDF/image through the system file picker.

Files live under the app documents directory in `attachments/`; the database only
stores a relative path. Individual attachments are limited to 25 MB. Images open
in an in-app full-screen viewer, other files open through the system viewer.
Deleting an attachment, or its expense/note/reminder, removes both the database
row and the file. Missing files are handled gracefully.

Xzifra requests no broad storage permission and no `INTERNET` permission.

## Home-screen widget

Add **Xzifra** from the Android widget picker. It shows the current month total
in the default currency, the next upcoming recurring payment/reminder when one
exists, and a `+` button that opens the new-expense form. Tapping the rest of the
widget opens the app.

The widget refreshes on app start/resume and when expenses, recurring rules or
reminders change. It does not run background refreshes, so a month rollover while
the app stays closed updates on the next open/resume. If nothing is upcoming the
footer is hidden.

## Launcher shortcuts

Long-press the Xzifra launcher icon for:

- **New expense** → `/add`
- **Reports** → `/reports`
- **New note** → `/notes/new`
- **New reminder** → `/reminders/new`

Labels follow the app language. Shortcut actions work from cold start and while
the app is running.

## Themes

| Preset | Look | Modes |
| --- | --- | --- |
| Indigo | Indigo accents on Material 3 surfaces | System, light, dark |
| Cyber Red | Black surfaces with neon red accents | Dark only |

Pick one in **Settings → Appearance**. The choice is stored in the local
database and travels with JSON backups.

## Data and backups

The database is stored in the app's private storage. Uninstalling the app deletes
it, so keep a backup somewhere safe.

**Settings → Backup** offers:

- **Export JSON backup** / **Import JSON backup** — records and settings only.
  Attachment metadata is intentionally excluded so JSON imports never point at
  missing files.
- **Export full backup (ZIP)** — `xzifra-backup.json` plus every attachment under
  `attachments/`.
- **Export CSV** — expenses for spreadsheets.

Full ZIP import extracts to a temporary directory, merges the JSON data, then
restores only attachments whose owner and file are present. Existing records win
on conflict. Duplicate or invalid attachments are skipped.

JSON, full ZIP and Markdown exports are shared through the Android share sheet
(Drive, email, etc.).

## Stack

| Layer | Choice |
| --- | --- |
| Framework | Flutter (Material 3) |
| State | Riverpod |
| Database | Drift (SQLite) with reactive queries |
| Navigation | go_router |
| Charts | fl_chart |
| Notifications | flutter_local_notifications + timezone |
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

## Localization

UI strings live in `app/lib/l10n/app_en.arb` and `app/lib/l10n/app_es.arb`.
The generated `AppLocalizations` files are committed, and `flutter gen-l10n`
regenerates them after editing an ARB file:

```bash
cd app
flutter gen-l10n
```

Language selection is stored in the local settings table (`system`, `en`, `es`).
Unsupported device languages fall back to English. Dates and numbers follow the
selected language; CSV exports keep dot decimals for spreadsheet compatibility.

## Build a release APK

```bash
./scripts/build-apk.sh
```

Output: `app/build/app/outputs/flutter-apk/app-release.apk`

The default build is a universal APK (~73 MB) that works on any device. For a
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

The build script injects the current commit, branch and UTC build date via
`--dart-define`, so the About page can show exactly which build is installed.

## Project structure

```
app/lib/
  core/        theme, settings, notifications, widget text, shared widgets
  data/        Drift schema, queries, seed, attachments, export/import
  domain/      money, periods, recurrence and report math (pure Dart, tested)
  features/    dashboard, records, expenses, notes, bookmarks, reminders,
               recurring, settings (incl. About)
  routing/     go_router configuration and app shell
app/test/      unit, database, export and widget tests
app/assets/    launcher icon sources
scripts/       build-apk.sh, generate_icon.py
docs/          signing notes
```

## Icon

The launcher icon is an original isometric cube with four corner dots, drawn
for Xzifra by xzero and licensed under the project's MIT license. Sources and
notice live in `app/assets/icon/`.

Regenerate the master PNGs and the Android resources with:

```bash
python3 scripts/generate_icon.py
cd app && dart run flutter_launcher_icons
```

## Out of scope

Budgets, income tracking, account balances, bank sync, multi-user support and
cloud sync.

## License

MIT — see [LICENSE](LICENSE). The launcher icon is an original isometric cube
drawn for Xzifra by xzero and covered by the same MIT license; see
`app/assets/icon/LICENSE-icon.txt` and the app's open-source licenses page.
