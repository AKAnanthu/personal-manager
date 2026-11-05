# Personal Life Manager

Local-first personal organiser for Android and iOS (Flutter). No developer
backend: all data stays on the device; the only network use is the user's own
Google Drive, and only on user action.

## Toolchain

The Flutter SDK is pinned with [FVM](https://fvm.app) (`.fvmrc` → 3.47.7).
Prefix every Flutter/Dart command with `fvm`.

```sh
fvm install            # once
fvm flutter pub get
fvm dart run build_runner build   # drift codegen (after editing tables/DAOs)
fvm flutter gen-l10n              # after editing lib/l10n/*.arb
fvm flutter analyze
fvm flutter test
```

## One-command scripts (Windows)

Run from the project folder (`cmd` or PowerShell):

| Command | Does |
|---------|------|
| `.\run.cmd` | clean → pub get → gen-l10n → run **dev** on the connected device |
| `.\run.cmd -NoClean` | same, skipping `flutter clean` (much faster) |
| `.\run.cmd -Flavor prod -Release -Device <id>` | prod flavor, release mode, chosen device |
| `.\run.cmd -Codegen` | also re-runs drift `build_runner` |
| `.\release.cmd` | clean → pub get → analyze → test → signed, obfuscated prod **APK + App Bundle** |
| `.\release.cmd -Target apk -Install` | only the APK, then install it on the phone |
| `.\release.cmd -SkipChecks` | skip analyze/tests |

Without `android/key.properties` the release is signed with debug keys (a
warning is printed): fine for your own phone, rejected by Google Play.

## Flavors

| Flavor | Android applicationId            | Config file          |
|--------|----------------------------------|----------------------|
| dev    | `app.plm.personal_life_manager.dev` | `config/dev.json`  |
| prod   | `app.plm.personal_life_manager`     | `config/prod.json` |

```sh
fvm flutter run --flavor dev --dart-define-from-file=config/dev.json
fvm flutter build appbundle --flavor prod --dart-define-from-file=config/prod.json \
  --obfuscate --split-debug-info=build/symbols
```

`config/*.json` hold **non-secret** values only. Keep the `build/symbols`
output of each release; it's needed to de-obfuscate stack traces.

**iOS flavors are not configured yet.** They need Xcode (build configurations
`Debug-dev`/`Release-prod`…, schemes `dev`/`prod`, per-flavor bundle IDs and
per-flavor Google OAuth URL schemes). Until then, iOS builds run without
`--flavor`.

## Privacy hardening (implemented)

- Android: `allowBackup="false"`, plus `fullBackupContent` and
  `dataExtractionRules` excluding every domain from cloud backup and device
  transfer.
- iOS: all data lives under `Application Support/plm_data/`, which is marked
  `NSURLIsExcludedFromBackupKey` on every launch (`AppDelegate.swift`,
  channel `app.plm/platform`).
- App lock: always locked on cold start; re-locks when the app returns from
  the background (timeout default: immediate). Pickers/camera/share sheets
  must be wrapped in `AppLock.runExternal` so they don't trigger a lock.
- App password: PBKDF2-HMAC-SHA256 (600k iterations, 16-byte salt) in the
  Keychain/Keystore, hashed off the UI isolate. 5 free attempts, then a
  30 s lockout that doubles per failure up to 15 min; persisted across
  restarts. Access control only, nothing is encrypted with it.
- A fresh install clears leftover Keychain items (iOS keeps them after
  uninstall), so a reinstall never asks for an old password.
- Recents/app switcher: Android 13+ hides every thumbnail
  (`setRecentsScreenshotEnabled(false)`); wrap sensitive screens in
  `SecureScreen` for `FLAG_SECURE`. iOS blurs the window while inactive
  (`SceneDelegate.swift`).
- Logs record only error types, never messages or record contents.
- No crash reporting or analytics in V1.

## Notifications

All scheduling goes through `NotificationScheduler`
(`lib/core/notifications/`). Features register a source provider and call
`replan()` after any change; the planner computes the full pending set and
the scheduler diffs it against the OS.

- **iOS 64-pending limit:** at most 60 are kept, medicine first, then
  reminders, then the rest, soonest first. Re-planned on every foreground.
- **OS-repeated vs expanded:** daily, weekly, monthly (days 1–28), yearly
  (not 29 Feb) and medicine times use one repeating OS notification each.
  Monthly on the 29th–31st and yearly on 29 Feb clamp to the month end, which
  the OS can't express, so the next 4 occurrences are scheduled and rolled
  forward when the app opens. If the app isn't opened for ~4 months, those
  stop until it is.
- **Exact alarms (Android 12+):** without the user's permission,
  notifications fall back to inexact timing (`exactAlarmsAvailable` lets the
  UI show a note and a shortcut).
- **Reboot / app update (Android):** the plugin's boot receiver restores
  pending notifications. **Timezone change:** detected when the app returns
  to the foreground; wall-clock times are kept (8:00 stays 8:00).
- **Snooze** (5/10/30 min) works from the notification, including when the
  app isn't running (background isolate).
- Notification permission is requested when the first reminder is created,
  not at setup.

## Backup & restore

Manual only; nothing is backed up or uploaded automatically.

- A backup is one `.plmbackup` file (a zip): `manifest.json` (format
  version, app version, schema version, categories, record counts and a
  SHA-256 for every part), `data/<category>.json` (raw table rows) and
  `files/<key>` (only attachments the included records use).
- Restore checks the manifest, rejects newer formats/schemas, verifies
  every checksum and refuses unsafe paths before anything changes.
- **Merge** upserts by id; the newer `updatedAt` wins. **Replace** clears
  the chosen categories first. One DB transaction per category; files are
  copied in before the transaction and removed again if it fails.
- Backups are not encrypted (PRD §17.6); the UI says so, more strongly
  when password notes are included.

## Forgotten password / erase all data

There is no server, so a forgotten app password can't be recovered. The
Unlock screen offers "Forgot password?" and Settings offers "Erase all
data": after the user types the confirmation word, every record, file,
notification, the password hash and preferences are deleted and the app
returns to first-time setup. Backup files and Drive copies are untouched.

## Tests

```sh
fvm flutter test                                  # unit + widget
fvm flutter test integration_test -d flutter-tester   # app flows, on the host
fvm flutter test integration_test --flavor dev -d <device id>
```

The integration tests run the real app with in-memory replacements for
storage, secure storage, biometrics and the notification plugin
(`DependencyOverrides` in `lib/app/di.dart`), so they never touch the
installed app's data or show permission dialogs.

## Release (Android)

1. Create an upload keystore (keep it outside the repo and backed up —
   losing it means you can't update the app on Play):
   `keytool -genkey -v -keystore plm-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Copy `android/key.properties.example` to `android/key.properties`
   (git-ignored) and fill it in. Without it, release builds are signed with
   debug keys and Gradle prints a warning; they can't be uploaded.
3. Build:
   `fvm flutter build appbundle --flavor prod --dart-define-from-file=config/prod.json --obfuscate --split-debug-info=build/symbols`
4. Keep `build/symbols` for each release (needed to read stack traces).

iOS release needs Xcode on a Mac (signing, flavors; see Flavors above).

## Google Cloud setup (needed from the Drive milestone)

1. Create a Google Cloud project and enable the **Google Drive API**.
2. OAuth consent screen: External, scope `https://www.googleapis.com/auth/drive.file`
   only (non-sensitive, so no restricted-scope verification).
3. Android OAuth client per flavor: package name from the table above plus the
   SHA-1 **and** SHA-256 of that flavor's signing key
   (`cd android && ./gradlew signingReport`).
4. iOS OAuth client per bundle ID; add its reversed client ID as a URL scheme
   in `Info.plist`.

## Layout

```
lib/app/       app widget, router (StatefulShellRoute), DI, flavor
lib/core/      db (drift), error (Result/Failure), storage, platform, ui/theme
lib/features/  one folder per module (added per milestone)
lib/l10n/      ARB strings (generated code in lib/l10n/gen, not committed by hand)
design/        approved screen designs (visual reference only)
```

Fonts: Plus Jakarta Sans is bundled in `assets/fonts` (SIL OFL 1.1, see
`assets/fonts/OFL.txt`) so the app works offline from first launch.
