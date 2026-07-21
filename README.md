# opencode-config

OpenCode 个人配置文件仓库。

## 插件

| 插件 | 用途 |
|------|------|
| [@cortexkit/opencode-magic-context](https://github.com/cortexkit/magic-context) | 自管理上下文与长期记忆 |
| [@mohak34/opencode-notifier](https://github.com/mohak34/opencode-notifier) | 任务完成通知 |

## MCP 服务

| 服务 | 用途 |
|------|------|
| [context7](https://github.com/upstash/context7-mcp) | 实时库文档查询 |
| [gh-mcp](https://github.com/modelcontextprotocol/server-github) | GitHub API 操作 |

## Deploy

```bash
./deploy.sh
```

首次 clone 后执行一次，完成：

1. 设置 git hooks 路径（`core.hooksPath = .githooks`）
2. 将 `configs/magic-context.jsonc` 部署到 `~/.config/cortexkit/`

之后每次 `git pull`，`.githooks/post-merge` 自动同步 Magic Context 配置。可随时手动执行 `./deploy.sh` 强制同步。

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
