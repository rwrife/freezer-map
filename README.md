# Freezer Map

A local-first mobile app for households to map freezer contents by appliance and bin, track portions and frozen dates, surface use-first items, and export inventory without accounts.

> **Status:** documentation and backlog scaffold only. No Flutter application, database, build, test result, screenshot, package, or store release exists yet.

## Why

Freezer contents disappear behind drawers and stacked containers. Paper lists go stale, generic pantry apps rarely model physical freezer locations, and account-based inventory products add friction for a small household task. Freezer Map is designed for the moment someone asks, “Do we still have soup, and where is it?”

## Target users

- Households with a chest freezer, upright freezer, or multiple fridge-freezer compartments
- Batch cooks who freeze meals in portions
- Gardeners, hunters, and bulk shoppers who rotate frozen food
- Anyone trying to reduce forgotten food without sharing an inventory with a cloud service

## Core workflows

1. **Set up locations:** name appliances, then add nested zones such as `Garage chest freezer / left basket`.
2. **Add an item quickly:** record a name, portion count, frozen-on date, optional use-first date, location, category, and note.
3. **Find it:** search or filter by appliance, zone, category, or status and see the exact stored location.
4. **Use or move portions:** decrement a quantity, mark portions as thawing, return them to frozen, move them, or archive an emptied entry. Every mutation is undoable during the session.
5. **Plan what to use:** review deterministic “use first” groups based on user-entered dates and a separate thaw queue.
6. **Own the data:** export versioned JSON for backup/restore and flat CSV for inspection or spreadsheet use; delete all local data from Settings.

## MVP

- Android and iOS from one Flutter codebase
- Appliance and nested zone management with stable IDs
- Local item records with portion quantity, frozen-on date, optional user-entered use-first date, category, location, notes, and timestamps
- Fast search plus appliance, zone, category, thawing, and archived filters
- Atomic quantity/move/thaw/archive actions with validation and undo
- Deterministic use-first view; no opaque scoring or AI dependency
- Optional local reminders for user-selected use-first dates and thaw checks
- Versioned JSON backup/restore, CSV export, and destructive-data controls
- Large text, screen-reader labels, non-color-only status, keyboard support where the platform provides it, and reduced-motion behavior

## Non-goals

- Food-safety certification, spoilage detection, shelf-life prediction, temperature monitoring, diagnosis, or health advice
- Automatic expiry claims derived from food type
- Recipe generation, grocery ordering, retailer integrations, or nutrition tracking
- Cloud accounts, remote household sync, social sharing, or subscriptions
- Barcode scanning, photos, OCR, and AI in the first MVP
- Managing room-temperature pantry or refrigerator inventory

## Privacy, permissions, and storage

Freezer Map is offline and local-first. Structured records live in an app-private SQLite database. Backups and exports are created only after an explicit user action using the platform document picker. The MVP requests no location, contacts, microphone, camera, health, Bluetooth, or background sensor permissions.

Notification permission is requested only when the user enables reminders. Denial leaves all inventory, search, use-first, and export features intact. Notifications contain an item name only when the user opts in; a privacy setting can use generic reminder text instead.

Exports can contain household inventory details, so the app warns before sharing and never uploads them itself. “Delete all data” requires confirmation and reports completion or failure. No analytics, advertising SDK, telemetry, or network service is planned for the MVP.

## Data model

- `Appliance`: stable ID, name, sort order, archived flag
- `Zone`: stable ID, appliance ID, optional parent zone ID, name, sort order
- `FreezerItem`: stable ID, name, category, location ID, quantity and unit, frozen-on date, optional use-first date, thaw state, notes, created/updated timestamps, archived timestamp
- `InventoryEvent`: item ID, action, before/after summary, timestamp; retained locally to support auditability and recovery without pretending to be immutable legal evidence
- `Reminder`: item ID, local schedule, privacy mode, enabled state

Dates are user-entered planning metadata, not food-safety determinations. The UI must preserve an explicit “date unknown” state instead of inventing one.

## Accessibility expectations

All primary flows must work with TalkBack and VoiceOver. Controls require semantic names and hints, logical focus order, at least 44×44 pt targets, and no color-only status. Layouts must remain usable at 200% text scale. Quantity changes require clear spoken feedback and an undo action. Motion is decorative and disabled when reduced motion is requested.

## Development quickstart (planned)

Prerequisites: Flutter stable, Dart bundled with Flutter, Android Studio/SDK for Android, and Xcode/CocoaPods on macOS for iOS.

```bash
flutter doctor
flutter pub get
flutter analyze
flutter test
flutter run
```

These commands describe the intended project workflow; they cannot run until issue #1 creates the Flutter project.

## Milestones

1. Reproducible Flutter skeleton, CI, and architectural seams
2. Tested local domain/database layer and migration contract
3. Complete add/find/use/move/thaw workflow
4. Accessible location-aware mobile UI
5. Backup, restore, CSV export, reminders, and privacy controls
6. Platform builds, release checklist, and documented limitations

See [PLAN.md](PLAN.md) for architecture and delivery order. Work is tracked in GitHub Issues.

## Limits and responsible use

Freezer Map is an organizational aid, not a food-safety instrument. It does not measure temperature, detect thawing or spoilage, validate safe storage duration, or tell anyone whether food is safe to eat. Users should follow local food-safety guidance and discard food when uncertain.

## License

MIT; see [LICENSE](LICENSE).
