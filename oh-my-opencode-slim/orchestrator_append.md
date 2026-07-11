## Background Task Stop Rule

- If a background specialist or terminal task is a dependency for the next step and no independent work remains, stop the current turn immediately.
- While waiting, do not call tools, poll task status, send progress messages, continue analysis, or produce a final answer early; wait for the hook-driven completion notification.
- After the completion notification arrives, reconcile and verify the result before continuing or replying to the user.
