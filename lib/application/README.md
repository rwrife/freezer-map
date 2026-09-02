# Application boundary

Commands, queries, validation orchestration, injected clocks/ID sources, and
undo results belong here. This layer may depend on `domain`, but not on Flutter,
data implementations, platform plugins, or presentation code.

`InventoryFilter` combines local search and explicit appliance, zone, category,
thaw, archive, and planning-date predicates. Use-first and thaw-queue ordering is
deterministic. Item commands return transactional `ItemChange` values for
session undo and reject stale undo attempts after a later mutation.
