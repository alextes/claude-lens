# CLAUDE.md

## 项目概述

claude-lens 是 Claude Code 的轻量 statusline，纯 Bash + jq，144 行单文件。

## 架构

`claude-lens.sh` 每 ~300ms 被 Claude Code 调用，输出两行 ANSI 着色文本：

- **行1:** `[模型 ●effort] 目录 | 分支 Nf +A -D`
- **行2:** `████░░ PCT% of SIZE | 5h: 余量% [±pace] | 7d: 余量% [±pace] | [extra] | [$cost] | 时长`

Usage 显示为**剩余百分比**（高=好=绿），pace delta 为**储备方向**（+N% 余裕绿，-N% 透支红，±10% 内不显示）。

数据源与缓存策略：

| 数据源 | 来源 | 缓存 |
|--------|------|------|
| 模型/上下文/时长/费用 | stdin JSON（`--slurpfile` 合并 settings） | 无需缓存 |
| Effort level | `~/.claude/settings.json` | 同上 jq 调用一并读取 |
| Git 分支 + diff | `git` 命令 | `/tmp` 文件缓存，TTL 5s |
| Usage API（5h/7d/extra/pace） | Anthropic OAuth API（`fromdateiso8601` 算剩余分钟） | `/tmp` 文件缓存，TTL 300s，异步后台刷新 |

## 关键设计约束

- **纯 Bash + jq** - 禁用 Node.js、Python
- **文件缓存** 存于 `/tmp`，`noclobber` 文件锁 + 原子写入（`mktemp` → `mv`）
- **优雅降级** - 失败时保留好数据 + touch 防重试风暴；仅无数据时写占位符
- **Stale-while-revalidate** - Usage API 后台子 shell 刷新，主进程不阻塞
- **条件显示** - Extra usage 仅 5h>=80% 时显示；会话费用仅 API 用户显示

## 历史

v0.3.1。从 v0.2.1（962 行）重构为 144 行极简方案。旧版本归档在 `_archive/`。
