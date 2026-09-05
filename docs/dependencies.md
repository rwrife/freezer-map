# Toolchain and dependency record

## Pinned toolchain

| Component | Pin | Source / integrity |
|---|---:|---|
| Flutter stable | 3.47.2 (`d3b14c8769`) | Official Linux release archive; SHA-256 `447878859d01ca9bfdb99a85f245af07ed8a15fedcd9d189c4749e8e92d1f185` |
| Dart (bundled release) | 3.13.2 | Flutter manifest pin; local ARM64 SDK SHA-256 `e4b2dd93bb3e7da2a2c5e1215d94c5da2e0ece0ed41b9f26c3d7e98baa659c7c` |

CI selects the exact Flutter version. The `pubspec.yaml` Dart range rejects a
different Dart minor. `pubspec.lock` pins hosted transitive packages and their
published SHA-256 values.

Flutter's official Linux archive for this release declares `dart_sdk_arch:
x64`. The project was created and its Dart gates were run locally on Linux
ARM64 by replacing only the bundled host Dart runtime with the official,
matching Dart 3.13.2 ARM64 SDK and rebuilding the Flutter tool snapshot. This
does not provide an Android SDK, macOS, Xcode, a simulator, signing, or physical
device evidence; those remain separate CI/platform gates.

## Direct packages and licenses

| Package | Version/source | Purpose | License |
|---|---|---|---|
| `flutter` | SDK from Flutter 3.47.2 | Material application framework | BSD 3-Clause |
| `flutter_test` | Flutter SDK | Unit and widget test harness | BSD 3-Clause |
| `flutter_lints` | 6.0.0 | Maintained baseline lint rules | BSD 3-Clause |
| `decimal` | 3.2.6 | Exact, non-binary portion quantities | Apache-2.0 |
| `drift` | 2.34.3 | Typed SQLite schema, queries, and transactions | MIT |
| `file_picker` | 12.2.0 | User-initiated scoped platform open/save document pickers | MIT |
| `flutter_local_notifications` | 17.2.4 | User-enabled local-only planning reminders | BSD-3-Clause |
| `path` | 1.9.1 | Portable app-private database path joining | BSD 3-Clause |
| `path_provider` | 2.1.6 | OS application-support directory lookup | BSD 3-Clause |
| `timezone` | 0.9.4 | Timezone-safe local reminder scheduling | MIT |
| `unorm_dart` | 0.3.2 | Unicode normalization for deterministic local search | MIT |
| `build_runner` | 2.16.0 (development only) | Deterministic code-generation runner | BSD 3-Clause |
| `drift_dev` | 2.34.5 (development only) | Drift schema/code generator | MIT |
| `file_picker_platform_interface` | 3.3.0 (test only) | Fakeable picker boundary for adapter tests | MIT |

Drift and its locked transitive `sqlite3` dependency provide the local database;
`path_provider` selects the operating system's app-private support directory.
`file_picker` delegates to the operating system's scoped document picker only
after an explicit open/save action; it requests no broad filesystem permission.
`flutter_local_notifications` schedules reminders on-device only and uses
notification permission only when the user explicitly enables reminders.
These packages add no account, analytics, advertising, telemetry, or
application network behavior. The native
SQLite library is resolved through Dart native assets; the obsolete
`sqlite3_flutter_libs` package is intentionally not used. Later package
additions must record purpose, version, license, privacy/permission impact, and
lockfile changes here.

Direct package license texts were checked from the resolved SDK and pub cache.
Transitive runtime/test/tool packages are locked in `pubspec.lock`; Flutter's
build-generated application license bundle remains the distribution source of
third-party notices.
