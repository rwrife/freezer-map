# Backup, restore, CSV, and deletion

## JSON backup version 1

Freezer Map writes UTF-8 JSON only after the user confirms the privacy warning
and chooses a destination in the operating system document picker. The app does
not request broad storage permission and does not upload the file.

The top-level envelope is:

```json
{
  "format": "freezer-map-backup",
  "version": 1,
  "exportedAt": "2026-09-04T12:00:00.000Z",
  "schema": {"application": "freezer-map", "database": 1},
  "data": {
    "appliances": [],
    "zones": [],
    "items": [],
    "events": [],
    "reminders": []
  }
}
```

All five record collections preserve their stable IDs and every persisted
field. Timestamps are UTC ISO-8601 strings ending in `Z`; unknown planning dates
and nullable relationships are JSON `null`. Quantities remain canonical decimal
strings so backup does not introduce binary floating-point rounding. `version`
controls the portable envelope; `schema.database` records the source database
schema. Version 1 is the migration baseline. A future reader must explicitly
migrate older supported versions before validation and reject newer or otherwise
unsupported versions rather than guessing.

## Restore contract

Restore has two deliberately explicit modes:

- **Replace** validates the entire file, displays a dry-run record summary, then
  atomically replaces all current local records after a second confirmation.
- **Merge** validates the entire file and adds its records atomically. Any stable
  ID already present in the same collection is rejected with the kind and ID;
  use Replace when restoring a backup of the same inventory.

Before either mode writes, the reader checks the envelope and schema, required
types, enum values, timestamps, unique IDs, domain constructors, positive active
quantities, appliance/zone/item relationships, same-appliance parents, dangling
event/reminder references, and zone cycles. A second collision check runs inside
the Merge transaction to catch data changes after the dry run. Insert order is
appliances, zones, items, events, reminders. Replace deletion and all inserts are
one database transaction; any constraint, I/O, or other failure rolls everything
back and the UI reports that local data is unchanged.

## CSV export

CSV is an inspectable item view with RFC-style doubled-quote escaping. It
contains item IDs and fields plus appliance name and a flattened `zone_path`.
It intentionally omits event history, reminders, appliance/zone stable IDs,
sort order, archived location metadata, and the full nested relationship graph.
It is therefore lossy and is never accepted as a complete restore format.

## Delete all

Delete all requires confirmation and removes reminder records, event history,
items, zones, and appliances inside one transaction. The service then counts all
five tables before commit. Any remaining row or database error rolls the change
back and is reported; success is shown only after zero rows are verified.

## Privacy and capabilities

JSON and CSV can expose household inventory, locations, notes, and schedules.
Keep backups private and review where they are shared. The implementation uses
`file_picker`, which delegates open/save choices to scoped platform document
pickers. It adds no location, contacts, camera, microphone, health, Bluetooth,
network, account, analytics, telemetry, advertising, or broad filesystem path.
Reminder scheduling and notification permission are separate future work.
