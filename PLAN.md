# Freezer Map implementation plan

## Scope

Freezer Map is a local-first Flutter application for Android and iOS. The MVP models freezer appliances, nested physical zones, portioned items, user-entered planning dates, a thaw queue, deterministic use-first sorting, reminders, and portable backup/export. It stays useful with every network interface disabled.

## Architecture

```text
Flutter UI (Material/Cupertino semantics)
        |
Application use cases + validation + undo results
        |
Domain models / deterministic policies
        |
Repository interfaces
        |
Drift repositories ---- SQLite app-private database
        |
Export/restore adapter -- versioned JSON + CSV via document picker
        |
Reminder adapter ------- platform local notifications (optional)
```

### Boundaries

- `domain`: immutable entities, quantity/date/location rules, search predicates, and use-first ordering; pure Dart with no Flutter dependency
- `application`: commands and queries for add, move, decrement, thaw, archive, restore, and undo
- `data`: Drift schema, migrations, transactions, repositories, JSON/CSV codecs
- `presentation`: accessible Flutter screens and state controllers
- `platform`: document picker and local-notification adapters behind interfaces

No domain behavior may depend on wall-clock globals. Tests inject a clock. Stable UUIDs and explicit schema versions make backup/restore deterministic.

## Technology choices

- **Flutter / Dart:** one maintained codebase with first-class Android and iOS accessibility APIs
- **Drift + SQLite:** typed queries, transactions, migrations, and predictable offline storage
- **Riverpod:** explicit dependency injection and testable state, without requiring generated global service locators
- **go_router:** typed, testable navigation and deep-link-safe screen state
- **flutter_local_notifications:** optional local reminders behind an adapter
- **file_selector / platform document picker:** user-mediated export and restore without broad filesystem permission
- **UUID package:** stable identifiers that survive export/restore

Package choices remain provisional until the skeleton issue records compatible pinned versions and licenses.

## Domain decisions

- Quantities are positive decimals plus a user-selected unit label; mutation happens in transactions and can never produce a negative quantity.
- A zero remainder archives the item after confirmation rather than silently deleting history.
- “Use first” orders explicit use-first date, then frozen-on date, then normalized name and stable ID. Missing dates remain grouped as unknown.
- Thaw state is an explicit user action with a timestamp; the app never infers safe thaw duration.
- Zones form an acyclic tree under one appliance. Moving/archive operations must preserve referential integrity.
- Restore validates the full archive before replacing or merging any records; failures leave the database unchanged.

## Milestones and dependencies

### M1 — Project foundation

Create the Flutter workspace, formatting/lint rules, test harness, CI matrix, architecture folders, and an app that starts on Android and iOS simulators where available.

### M2 — Local data and policies

Implement models, Drift schema, migrations, repositories, injected clock/IDs, transactional commands, deterministic ordering, and unit/property tests. Depends on M1.

### M3 — Primary workflow

Build appliance/zone setup, quick add/edit, search/filter, item detail, decrement/move/thaw/archive actions, undo feedback, and empty/error states. Depends on M2.

### M4 — Accessible interaction

Complete semantic labels, focus order, dynamic text, target sizing, non-color-only state, reduced motion, TalkBack/VoiceOver manual scripts, and widget tests. Builds on M3 rather than postponing accessibility to release day.

### M5 — Data ownership and reminders

Add versioned JSON backup/restore, CSV export, delete-all controls, reminder privacy settings, just-in-time notification permission, and denial/error paths. Depends on stable M2 schema and M3 screens.

### M6 — Packaging and release candidate

Produce unsigned reproducible debug/release builds, smoke-test migration/restore, document signing and store steps without checking in secrets, create privacy metadata, and publish checksums for release artifacts when a real release exists.

## Testing strategy

- **Unit:** quantity invariants, zone acyclicity, use-first ordering, date-unknown behavior, search normalization, archive and thaw transitions
- **Property/fuzz:** action sequences never create negative quantities or dangling locations; JSON round trips preserve supported records
- **Database:** migrations from every committed schema version, transactional rollback, repository queries, concurrent command serialization
- **Widget:** add/find/use/move/thaw flows, undo, empty/error/loading states, 200% text scale, semantic labels and focus order
- **Golden:** a small reviewed set at normal/large text and light/dark themes; never the sole accessibility evidence
- **Integration:** fresh install, populated upgrade, backup/export, destructive restore rollback, delete all, notification granted/denied, airplane-mode operation
- **CI:** format, static analysis, unit/widget/database tests on Linux; Android build; iOS build without signing on macOS when the workflow is enabled
- **Manual:** TalkBack and VoiceOver scripts on at least one real or simulator device per platform before release

Tests will distinguish automated results from manual platform observations. No physical-device claim is allowed without recorded evidence.

## Backup and compatibility

JSON backup uses a documented envelope with format version, exported timestamp, app schema version, and record arrays. Import first parses, validates IDs/references/types/ranges, and reports a dry-run summary. The user chooses replace or merge; replace writes to a new transaction and commits only after full validation. CSV is export-only and clearly documented as lossy for nested zones and event history.

## Permissions and privacy

Baseline operation needs no runtime permission. Notification permission is requested only after an explicit enable action. Export/restore uses scoped document-picker access. The app includes no account, ad SDK, analytics, telemetry, or network API. Dependency review rejects packages that add undeclared network behavior.

## Packaging and distribution

- Android: reproducible APK/AAB build instructions, signing through local/CI secrets, Play Data Safety notes, and sideloadable release artifact
- iOS: Xcode archive/TestFlight/App Store instructions; signing identities remain outside git
- GitHub Releases: source archive, checksums, changelog, and build provenance when artifacts actually exist
- Versioning: semantic app version plus monotonically increasing platform build numbers and explicit database/backup schema versions

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| Inventory becomes stale | Make decrement/move actions one tap, preserve undo, and surface “last updated” without guilt-based notifications |
| Date fields imply safety | Call them planning dates, never compute safety windows, keep unknown explicit, show limits in onboarding/export |
| Nested locations become cumbersome | Support shallow defaults, reorderable zones, recent locations, and clear path breadcrumbs |
| Quantity edits lose data | Transactional commands, validation, event records, confirmation on archive, and undo |
| Restore corrupts local state | Validate first, transactionally apply, test all migrations, and retain the original file unchanged |
| Notifications expose item names | Generic-text privacy mode and opt-in permission/settings |
| Cross-platform behavior diverges | Adapter contracts, simulator/device scripts, and platform-specific CI builds |

## Explicit non-goals

Food-safety advice, temperature monitoring, spoilage prediction, recipe planning, grocery commerce, nutrition tracking, shared cloud inventory, barcode/photo/OCR capture, AI recommendations, pantry/fridge scope, and web/desktop clients are outside the MVP.

## Definition of MVP done

All seven scaffold issues are closed through reviewed PRs; format/analyze/tests and platform builds have recorded output; airplane-mode workflows pass; backup/restore and migration tests pass; accessibility scripts are documented; permissions and privacy copy match actual behavior; and a release candidate can be built without fabricated signing, store, or device-test claims.
