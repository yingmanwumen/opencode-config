---
description: Delete inactive historical sessions for the current project
---

Delete inactive historical OpenCode sessions for the current location:

1. List sessions with `opencode api GET /api/session --param directory="$PWD"`. For each page, pass its `cursor.next` value as `--param cursor="..."` to fetch the next page, and stop when `cursor.next` is absent. Track cursors already requested; if a cursor repeats or a page makes no progress, stop and report the pagination error instead of looping. Also call `opencode api GET /api/session/active`.
2. Identify inactive root sessions (no `parentID`), excluding roots in the current command's session tree or with active descendants. Report the location and count. If count is zero, stop.
3. Ask for confirmation with **Delete** and **Cancel** choices. On **Delete**, issue all `opencode api DELETE /api/session/{sessionID}` requests together, in parallel, for the eligible root IDs. Report the number deleted and any failed IDs.
