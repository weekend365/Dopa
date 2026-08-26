# Dopa domain

Pure Dart domain models and policies shared by Dopa clients. This package has no
Flutter, persistence, network, or analytics dependencies.

The tree companion is device-local. Storage adapters must execute
`FocusTreeRepository.writeTransaction` atomically and enforce both of these
unique constraints for growth credits:

- `sourceSessionId`
- `(treeId, creditedLocalDate)`

`CompleteFocusSession` always credits the `startedLocalDate` captured when the
session began. Completion time, midnight crossings, and later timezone changes
therefore cannot move a growth day.

Call `EnsureTreeCompanion` after login and local-data consent to create the seed
idempotently. `CompleteFocusSession` also uses the same get-or-create operation
inside its transaction so a missing initialization callback cannot lose an
otherwise valid focus completion.

Focus plans use `SessionDurationPreset` and therefore accept only 5, 10, 25, or
50 minutes. `protectedDuration`, protection mode, and five-minute bypass use are
retained for local reporting but do not affect growth eligibility.
