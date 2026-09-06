# Release candidate checklist (issue #7)

This checklist defines what must be true before declaring a reproducible
Freezer Map release candidate.

Freezer Map remains a local organizational aid. It is **not** a food-safety,
spoilage-detection, temperature-monitoring, diagnosis, treatment, nutrition,
or emergency product.

## Scope and intent

- Local-first and offline primary workflows remain mandatory.
- No cloud account, analytics, telemetry, ad SDK, or undeclared network behavior.
- Structured records remain app-private SQLite only.
- Backup/restore remains user-initiated, versioned, validated, and transactional.
- CSV remains intentionally lossy and export-only.

## Dependency-ready baseline

Issue #7 depends on issues #1–#6. The release candidate must carry those
outcomes forward and verify them as a coherent product:

| Issue | Capability carried into RC | Evidence surface |
|---|---|---|
| #1 | Flutter scaffold, CI, architecture layout | `.github/workflows/ci.yml`, `tool/check_architecture.dart`, `test/architecture_test.dart` |
| #2 | Drift schema + local persistence contracts | `test/data/app_database_test.dart`, `test/data/drift_repository_test.dart`, `test/data/database_schema_test.dart` |
| #3 | Appliance/zone setup and quick-add workflows | `test/presentation/inventory_workflows_test.dart` |
| #4 | Find/use/move/thaw queue workflows | `test/presentation/inventory_browser_workflows_test.dart`, `test/application/inventory_commands_test.dart`, `test/application/inventory_query_test.dart` |
| #5 | Backup/restore/CSV/delete-all data ownership controls | `test/data/data_portability_test.dart`, `test/presentation/data_settings_screen_test.dart`, `docs/backup-format.md` |
| #6 | Optional local reminders + accessibility hardening | `test/application/reminders_test.dart`, `test/presentation/reminder_workflows_test.dart`, `docs/reminders-accessibility.md` |

## Required automated verification commands

Run these commands from a clean checkout:

```bash
flutter --version
flutter pub get --enforce-lockfile
git diff --exit-code
dart run build_runner build
git diff --exit-code
dart format --output=none --set-exit-if-changed .
dart run tool/check_architecture.dart
dart run tool/check_release_readiness.dart
flutter analyze --fatal-infos --fatal-warnings
flutter test --coverage
flutter build apk --release
flutter build ios --release --no-codesign
```

Notes:
- Linux hosts without Android SDK or Xcode cannot provide both platform build
  artifacts locally; CI evidence is required in that case.
- `flutter build ios --release --no-codesign` is compile-only evidence and does
  not imply archive signing, TestFlight upload, or App Store publication.

## Integration scenario matrix

The following scenarios must be exercised by real tests or scripted checks:

| Scenario | Evidence command |
|---|---|
| Fresh install bootstrap behavior | `flutter test test/presentation/app_initialization_test.dart` |
| Populated restart persistence | `flutter test test/presentation/app_initialization_test.dart` |
| Schema contract / migration baseline | `flutter test test/data/database_schema_test.dart` |
| JSON backup + restore (replace/merge) | `flutter test test/data/data_portability_test.dart` |
| Restore rollback on failure | `flutter test test/data/data_portability_test.dart` |
| CSV export behavior | `flutter test test/data/data_portability_test.dart` |
| Delete all with post-delete verification | `flutter test test/data/data_portability_test.dart` |
| Reminder permission granted/denied paths | `flutter test test/application/reminders_test.dart` |
| Airplane-mode primary workflows | `dart run tool/check_release_readiness.dart` + `flutter test` (no network dependencies/permissions and local workflow tests) |

## Privacy, dependency, and manifest checks

`dart run tool/check_release_readiness.dart` must pass and enforces:

- Android permissions restricted to `POST_NOTIFICATIONS` only.
- iOS Info.plist excludes sensitive camera/microphone/location/contacts/
  bluetooth/health usage declarations.
- Forbidden network/telemetry/ad dependencies are absent in `pubspec.lock`.
- Network client patterns (`package:http`, `dio`, `HttpClient`, sockets,
  websocket connect calls) are absent under `lib/`.

## Accessibility checklist (report by evidence type)

### Automated (required)

- Widget tests covering semantic labels and 200% text scale pass:
  - `test/presentation/reminder_workflows_test.dart`
  - `test/presentation/data_settings_screen_test.dart`

### Emulator/simulator/manual (recommended pre-release)

- Android TalkBack checklist from `docs/reminders-accessibility.md`
- iOS VoiceOver checklist from `docs/reminders-accessibility.md`

### Physical-device manual (required before public store release)

- TalkBack on at least one real Android device.
- VoiceOver on at least one real iOS device.

These observations must be logged separately from automated and
simulator/emulator checks.

## Versioning, packaging, and release assets

- App version is declared in `pubspec.yaml` as semantic version + build number.
- Release notes are tracked in `CHANGELOG.md`.
- Signing instructions remain secret-free and external to git.
  See `docs/signing-and-packaging.md`.
- CI `release_assets` job runs only after quality + Android + iOS build jobs and
  publishes source archive, checksum, and `provenance.json` artifacts.

Suggested source provenance commands (run only after successful verification):

```bash
mkdir -p dist
TAG_OR_SHA=$(git rev-parse --short=12 HEAD)
git archive --format=tar.gz --output="dist/freezer-map-${TAG_OR_SHA}.tar.gz" HEAD
sha256sum "dist/freezer-map-${TAG_OR_SHA}.tar.gz" > "dist/freezer-map-${TAG_OR_SHA}.sha256"
```

Only publish release artifacts when platform builds actually succeed.
Clearly mark artifact status as unsigned/signed.

## Known constraints

- This repository intentionally carries no signing keys, provisioning profiles,
  or store credentials.
- CI and Linux host checks do not substitute for physical-device accessibility
  verification.
- No claim of store publication or real-device observation is valid without
  direct evidence.
