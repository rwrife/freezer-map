# Architecture boundaries

Freezer Map keeps policy independent from Flutter widgets and plugins. The
intended dependency direction is:

```text
presentation -> application -> domain
                     ^             ^
                     |             |
                   data         platform
```

Concrete adapters are composed at the app boundary; domain and application
code depend on contracts, not plugin implementations.

## Layer rules

| Layer | Responsibilities | May import |
|---|---|---|
| `domain` | Immutable entities, value objects, repository contracts, deterministic policies | `domain` only |
| `application` | Commands, queries, validation orchestration, injected clocks/IDs, undo results | `application`, `domain` |
| `data` | Drift schema/migrations, transactions, repositories, JSON/CSV codecs | `data`, `application`, `domain` |
| `presentation` | Accessible Flutter screens, widgets, UI state | `presentation`, `application`, `domain` |
| `platform` | Document picker and optional local-notification adapters | `platform`, `application`, `domain` |

Cross-layer imports use `package:freezer_map/...`; the analyzer's
`always_use_package_imports` rule prevents relative paths from bypassing the
checker. `dart run tool/check_architecture.dart` enforces the table for every
Dart source under `lib/`.

## Dependency and privacy rules

- `domain` remains pure Dart and has no Flutter or plugin imports.
- Presentation never constructs concrete database or platform adapters.
- No layer uses a wall-clock global for domain decisions; application code
  receives clocks and identifier sources.
- Structured records live in schema-versioned app-private SQLite through Drift.
- Baseline inventory requires no runtime permission or network access.
- Backup/export and notification capabilities remain explicit, user-initiated
  platform adapters in later issues.
- Generated Dart files use `.g.dart` or `.freezed.dart` suffixes and are
  explicitly excluded from hand-authored analysis; generation steps must be
  deterministic and checked separately when generators are introduced.
