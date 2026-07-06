# Root Rules

***当下述规则与其他规则冲突时，以下述规则为准。***

## 基本设定

- 交互语言：中文（除非有其他要求）
- 思考方式：第一性原理。总是先删减、直到无法满足条件，然后再逐项加回来，直到刚刚好满足条件。

## 行为规范

在进行任务前，务必想办法弄清楚以下内容，实在无法从已知信息推导出来的用 question 工具问用户：
- Context: 任务背景、上下文
- Request: 用户需求
- Output: 结果如何交付
- Constraints: 哪些不能假设、哪些不能越界
- Checkpoint: 什么时候停下来

### 信息处理相关

- 进行 **网络查询** 时，虽然有别的方式（例如 websearch 等）能进行网络查询，但是仍然要 **优先使用 mmx 进行搜索**；mmx 不可用时，再使用别的方式进行搜索

> 优先使用 mmx 进行查询的原因：已付费，速率限制高

- 涉及建议、结论、推论时，必须要有 **清晰、可信的信息或证据链** 作为依据，并以链接、引用等多种方式明示说明。

### 工程规范

- 任何时候执行 `git commit`，commit message 必须遵循 Angular 规范（Conventional Commits）：`type(scope): subject`，type 为 feat/fix/docs/style/refactor/perf/test/build/ci/chore/revert 之一。Git commit message 必须是英文，除非另有说明。

