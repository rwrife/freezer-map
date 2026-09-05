# Reminders and accessibility verification

This document captures the reminder privacy contract, manual accessibility
scripts, and verification evidence for issue #6.

## Reminder privacy + permission contract

- Notification permission is requested only after a user explicitly enables a
  reminder from an item card.
- Denying or cancelling permission leaves inventory, search, use-first, thaw
  queue, backup/restore/export, and delete-all workflows functional.
- Reminder text supports two privacy modes:
  - `Generic text`: no item name appears in the notification.
  - `Include item name`: item name appears in title/body.
- Reminder schedules are tied to stable reminder IDs and reconciled from local
  SQLite data on startup, after data restore, and when the app resumes
  (covering permission and timezone changes where supported by the platform).
- Notification taps are parsed as item/reminder IDs and handled safely when the
  item is missing, moved, or archived (user receives an in-app notice instead
  of a crash).

## Platform permission declarations

- Android manifest declares only:
  - `android.permission.POST_NOTIFICATIONS`
- No baseline location, contacts, microphone, camera, Bluetooth, health, or
  broad filesystem permission was added.
- No analytics, telemetry, ad SDK, or cloud sync service was added.

## Manual accessibility scripts

### TalkBack (Android)

1. Enable TalkBack in Android accessibility settings.
2. Launch Freezer Map and move focus through Inventory, Use First, and Thaw
   Queue tabs.
3. Verify item cards speak item name, quantity+unit, breadcrumb location, and
   explicit state text (Frozen/Thawing/Archived).
4. Open an item reminder dialog and verify:
   - Enable switch is reachable and announced.
   - Date/time controls and privacy mode are reachable at 200% text scale.
   - Save/Disable and Cancel controls are reachable and operable.
5. Trigger a reminder notification in each privacy mode and verify announced
   text matches selected privacy mode.
6. Deny notification permission, return to app, and verify non-reminder
   workflows still succeed.

### VoiceOver (iOS)

1. Enable VoiceOver in iOS accessibility settings.
2. Repeat the same interaction script used for TalkBack.
3. Confirm reduced motion mode keeps workflows usable with no required gesture
   alternatives hidden behind animation.
4. Confirm item/action controls remain at least 44×44 pt touch targets.

## Execution evidence for this run

Automated evidence collected on Linux ARM64:

- `dart run build_runner build`
- `dart run tool/check_architecture.dart`
- `flutter analyze --fatal-infos --fatal-warnings`
- `flutter test`

Manual-device evidence:

- Android emulator/device TalkBack: **not executed on this host**
- iOS simulator/device VoiceOver: **not executed on this host**

Reason: this cron host has no Android SDK/emulator or Xcode/iOS simulator
runtime. Device/simulator-only checks remain pending and must be run on
platform-capable hardware before release packaging (issue #7).
