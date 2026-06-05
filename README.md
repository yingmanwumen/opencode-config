# opencode-config

OpenCode 个人配置文件仓库。

## Tmux support

```bash
# Alias to the real opencode binary so tmux runs the correct command.
# Re-alias only if _opencode isn't already defined.
if ! command -v _opencode &>/dev/null; then
        alias _opencode=$(command -v opencode)
fi
opencode() {
        # If we're not inside a tmux session, start one.
        # Fall through to run opencode directly if tmux fails.
        if [[ -z "$TMUX" ]]; then
                printf -v _cmd 'opencode %q ' "$@"
                tmux new-session "${_cmd% }" && return
        fi
        # Already inside tmux — use a random port to avoid conflicts.
        local port
        port=$(shuf -i 49152-65535 -n 1)
        OPENCODE_PORT="$port" _opencode --port "$port" "$@"
}
```

## Dependencies

### Cli tools

- [lark-cli](https://github.com/larksuite/cli)
- [minimax-cli](https://platform.minimaxi.com/docs/token-plan/minimax-cli)

### Plugins

- [opencode-pty](https://github.com/shekohex/opencode-pty)
- [opencode-notifier](https://github.com/mohak34/opencode-notifier)
- [plannotator](https://github.com/backnotprop/plannotator#install-for-opencode)
- [oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim)
