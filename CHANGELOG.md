# Changelog

All notable changes to Freezer Map are documented here.

The project follows semantic versioning for app releases, while SQLite schema
and backup envelope versions are tracked separately in code/docs.

## [0.1.0-rc.1] - 2026-09-06

### Added
- Release candidate checklist with explicit offline/privacy/accessibility
  verification scope (`docs/release-candidate.md`).
- Deterministic release-readiness checker for permissions, privacy-sensitive
  platform keys, and forbidden network/telemetry dependencies
  (`tool/check_release_readiness.dart`).
- CI artifact upload for Android release APK output.

### Changed
- CI now builds Android **release** APK instead of debug APK.
- CI iOS build now compiles **release** with `--no-codesign`.
- README status and quickstart now reference release-candidate verification,
  privacy checker, and release build expectations.
- App version bumped to `0.1.0-rc.1+7`.

### Notes
- This release candidate remains unsigned by design. Signing credentials,
  store publication, and physical-device accessibility observations are tracked
  as external operational steps and are not committed to this repository.

## [0.1.0] - Unreleased

- Initial planned stable release after RC validation and external signing/
  distribution steps.
