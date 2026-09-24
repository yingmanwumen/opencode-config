---
description: Delete all OpenCode sessions
---

Delete every OpenCode session.

1. List all sessions with `opencode api GET /api/session --param limit=1000`. Do not pass a `directory` parameter. Parse the response JSON and collect every session ID from `data`. If `cursor.next` is present, request the next page with `opencode api GET /api/session --param limit=1000 --param "cursor=$NEXT_CURSOR"`, using the exact cursor value returned by the API. Continue until there is no next cursor.
2. Delete every collected session by calling `opencode api DELETE /api/session/{sessionID}` for each ID. Delete sessions in parallel. Do not filter by location, parent, activity, or whether a session is the current session. Do not ask for confirmation.
3. Report the total number of sessions deleted and any IDs whose deletion failed.
