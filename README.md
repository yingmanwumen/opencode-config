# opencode-config

OpenCode 个人配置文件仓库。

Tmux support:

```bash
alias _opencode=$(which opencode)
opencode() {
	local port
	port=$(shuf -i 49152-65535 -n 1)
	OPENCODE_PORT="$port" \
		_opencode --port "$port" "$@"
}
```
