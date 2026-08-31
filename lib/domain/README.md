# Domain boundary

Pure Dart entities, value objects, repository contracts, and deterministic
policies belong here. This layer must not import Flutter, plugins, or any other
Freezer Map layer.

The domain models exact decimal quantities, typed stable IDs, explicit known or
unknown planning dates, appliance/zone/item/event/reminder entities, acyclic
zone trees, item transition rules, deterministic use-first ordering, and
Unicode-normalized local search. Dates remain user-entered planning metadata;
no policy infers safety, spoilage, shelf life, or thaw duration.
