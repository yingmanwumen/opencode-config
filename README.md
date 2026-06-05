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
	# Run opencode directly if arguments are provided
	if [[ $# -gt 0 ]]; then
		_opencode "$@"
		return
	fi

	# If no arguments are provided, generate a random port and start tmux
	local port
	port=$(shuf -i 49152-65535 -n 1)
	# If we're not inside a tmux session, start one.
	# Fall through to run opencode directly if tmux fails.
	if [[ -z "$TMUX" ]]; then
		tmux new-session \
			-e OPENCODE_PORT="$port" \
			"opencode --port $port" && return
	fi
	# Already inside tmux — use a random port to avoid conflicts.
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
