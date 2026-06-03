# opencode-config

我的 [OpenCode](https://opencode.ai) 个人配置文件仓库，通过 `oh-my-opencode-slim` 编排多 Agent 协作。

## 核心配置 (`opencode.json`)

| 配置项 | 值 | 说明 |
|--------|-----|------|
| **默认模型** | `opencode-go/deepseek-v4-pro` | Orchestrator 主模型 |
| **Shell** | `/bin/zsh` | 交互 shell |
| **权限模式** | `allow` | 允许所有操作（非交互确认） |

### Agent 编排 (`oh-my-opencode-slim.json`)

通过 [oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim) 插件，配置了一支专业化 Agent 团队。当前激活 **`my-preset`**，全部使用 DeepSeek 模型：

| Agent | 模型 | 角色 |
|-------|------|------|
| @orchestrator | `deepseek-v4-pro` | 主控，统筹委派 |
| @oracle | `deepseek-v4-pro` (max) | 架构决策 / 代码审查 / 复杂调试 |
| @explorer | `deepseek-v4-flash` | 代码库搜索 / 模式匹配 |
| @librarian | `deepseek-v4-flash` | 查阅最新库 / SDK 文档 |
| @designer | `deepseek-v4-pro` (medium) | UI/UX 设计与视觉打磨 |
| @fixer | `deepseek-v4-flash` (high) | 快速执行明确编码任务 |
| @observer | `deepseek-v4-flash` | 图片 / PDF / 图表分析 |

**备选 Preset**（修改 `preset` 字段切换）：

- `openai` — OpenAI 模型 (gpt-5.5 / gpt-5.4-mini)
- `opencode-go` — 国产模型混搭 (智谱 GLM-5.1 + DeepSeek + Kimi + MiniMax)
- `deepseek-preset` — DeepSeek 官方 provider

### MCP 服务

| 服务 | 用途 |
|------|------|
| `context7` | 实时库/SDK 文档查询 |
| `gh-mcp` | GitHub 操作（Repo、Issue、PR 管理） |
| `notion` | Notion 文档与数据库操作（Token 通过 `NOTION_TOKEN` 环境变量注入） |

### 插件

| 插件 | 用途 |
|------|------|
| `opencode-pty` | PTY 终端持久化会话 |
| `opencode-notifier` | ntfy.sh 桌面通知 |
| `plannotator` | 计划注解与目标管理 |

## Skills（技能包）

32 个技能，覆盖飞书全系列 + 效率工具：

- **飞书系列**：IM、文档、日历、多维表格、审批、任务、会议、OKR、邮箱、画板等
- **AI 工具**：MiniMax (mmx-cli)、Agent Browser
- **效率工具**：简码 (simplify)、代码地图 (codemap)

## 行为规则 (`AGENTS.md`)

- 交互语言：中文
- 网络搜索优先用 MiniMax (mmx)
- 角色扮演：牧濑红莉栖（助手）

## 如何使用

### 环境要求

- [OpenCode](https://opencode.ai/docs) 已安装
- [Bun](https://bun.sh)（安装插件用）
- 配置好的 API provider 认证：`opencode auth login`

### 安装

```bash
# 克隆到 OpenCode 配置目录
git clone git@github.com:yingmanwumen/opencode-config.git ~/.config/opencode

# 安装插件依赖
cd ~/.config/opencode
bun install

# 刷新可用模型
opencode models --refresh

# 设置环境变量
export NOTION_TOKEN="your-notion-token"
```

### 验证

启动 OpenCode 后输入：

```
ping all agents
```

确认所有 Agent 在线。

### 修改配置

- 编辑 `oh-my-opencode-slim.json` 切换 preset 或调整 Agent 模型
- 编辑 `AGENTS.md` 定制行为规则
- 配置文件版本化：直接改 + `git commit` + `git push`
