# Data boundary

Drift tables, migrations, transactions, repository implementations, and
backup/export codecs belong here. This layer may implement contracts from
`domain` and support application use cases; it must not import presentation or
platform code.

Schema version 1 stores appliances, zones, items, append-only-in-normal-use
inventory events, and reminders in SQLite with foreign keys and query indexes.
`openAppPrivateDatabase` places the database under the operating system's
application-support directory through `path_provider`; it requests no broad
filesystem permission. Application commands perform item writes and event
appends in one transaction. `committedSchemaVersions` and its test must be
extended whenever a migration version is added.
