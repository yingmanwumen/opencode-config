# opencode-config

OpenCode 个人配置文件仓库。

## Tmux

```bash
if ! command -v _opencode &>/dev/null; then
	alias _opencode=$(command -v opencode)
fi
opencode() {
	if [[ $# -gt 0 ]]; then
		_opencode "$@"
		return
	fi
	local port
	port=$(shuf -i 49152-65535 -n 1)
	if [[ -z "$TMUX" ]]; then
		tmux new-session \
			-e OPENCODE_PORT="$port" \
			"opencode --port $port" && return
	fi
	OPENCODE_PORT="$port" _opencode --port "$port" "$@"
}
```

## CLI 工具

- [minimax-cli](https://platform.minimaxi.com/docs/token-plan/minimax-cli)
