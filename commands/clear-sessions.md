---
description: Delete all OpenCode sessions
---

!`response=$(opencode api get /api/session --param limit=1000) || exit; ids=$(jq -r '.data[].id' <<<"$response") || exit; total=0; deleted=0; failed=''; while IFS= read -r id; do [ -n "$id" ] || continue; total=$((total+1)); if opencode api delete "/api/session/$(jq -rn --arg id "$id" '$id|@uri')" >/dev/null 2>&1; then deleted=$((deleted+1)); else failed="$failed $id"; fi; done <<<"$ids"; printf 'Found: %s; deleted: %s; failed IDs:%s\n' "$total" "$deleted" "$failed"`
