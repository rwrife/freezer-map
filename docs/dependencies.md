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

No runtime third-party package, analytics, advertising, account, networking,
database, filesystem, notification, or permissions plugin is included in this
foundation. Later package additions must record purpose, version, license,
privacy/permission impact, and lockfile changes here.

Flutter and `flutter_lints` license texts were checked from the resolved SDK and
pub cache. Transitive test/tool packages are locked in `pubspec.lock`; Flutter's
build-generated application license bundle remains the distribution source of
third-party notices.
